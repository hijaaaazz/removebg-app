import 'dart:io';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/gallery_saver_service.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/services/share_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/canvas/backdrop_selector_bar.dart';
import 'package:removeit_app/core/widgets/canvas/checkerboard_background.dart';
import 'package:removeit_app/core/widgets/canvas/comparison_slider.dart';
import 'package:removeit_app/core/widgets/canvas/zoomable_canvas.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/core/widgets/monetization/quota_pill_badge.dart';
import 'package:removeit_app/core/widgets/monetization/watch_ad_prompt_sheet.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/claim_job_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/poll_job_status_usecase.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';
import 'package:removeit_app/features/studio_canvas/presentation/bloc/studio_canvas_cubit.dart';
import 'package:removeit_app/injection_container.dart';

class StudioCanvasScreen extends StatelessWidget {
  final String jobId;
  final File? originalFile;

  const StudioCanvasScreen({
    super.key,
    required this.jobId,
    this.originalFile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudioCanvasCubit(),
      child: _StudioCanvasScreenContent(jobId: jobId, originalFile: originalFile),
    );
  }
}

class _StudioCanvasScreenContent extends StatefulWidget {
  final String jobId;
  final File? originalFile;

  const _StudioCanvasScreenContent({required this.jobId, this.originalFile});

  @override
  State<_StudioCanvasScreenContent> createState() => _StudioCanvasScreenContentState();
}

class _StudioCanvasScreenContentState extends State<_StudioCanvasScreenContent> {
  JobEntity? _job;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  double? _imageAspectRatio;
  final GlobalKey _canvasRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resolveImageDimensions();
    _loadJobDetails();
    // Fetch real-time authoritative quota status
    context.read<QuotaBloc>().add(const FetchQuotaEvent());
  }

  Future<void> _resolveImageDimensions() async {
    if (widget.originalFile != null) {
      try {
        final bytes = await widget.originalFile!.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        if (mounted && frame.image.height > 0) {
          setState(() {
            _imageAspectRatio = frame.image.width / frame.image.height;
          });
        }
      } catch (_) {}
    }
  }

  void _resolveAspectRatioFromNetwork(String url) {
    if (url.isEmpty || _imageAspectRatio != null) return;
    final provider = CachedNetworkImageProvider(url);
    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (mounted && info.image.height > 0) {
          setState(() {
            _imageAspectRatio = info.image.width / info.image.height;
          });
        }
      }),
    );
  }

  Future<void> _loadJobDetails() async {
    final pollUseCase = sl<PollJobStatusUseCase>();
    final result = await pollUseCase(widget.jobId);

    if (mounted) {
      result.fold(
        (failure) => setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        }),
        (job) => setState(() {
          _isLoading = false;
          _job = job;
          if (job.width != null && job.height != null && job.height! > 0) {
            _imageAspectRatio ??= job.width! / job.height!;
          }
        }),
      );
    }
  }

  Future<String?> _exportCompositeImage(StudioCanvasState canvasState) async {
    final cubit = context.read<StudioCanvasCubit>();
    final wasCompareActive = canvasState.isCompareActive;
    if (wasCompareActive) {
      cubit.toggleCompare();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    try {
      final boundary =
          _canvasRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final tempPath =
          '${Directory.systemTemp.path}/composite_${_job?.id ?? DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return tempPath;
    } catch (_) {
      return null;
    } finally {
      if (wasCompareActive && mounted) {
        cubit.toggleCompare();
      }
    }
  }

  Future<void> _claimAndSave(StudioCanvasState canvasState) async {
    if (_job == null) return;
    HapticService.light();
    setState(() => _isSaving = true);

    try {
      final claimUseCase = sl<ClaimJobUseCase>();
      final claimResult = await claimUseCase(_job!.id);

      // Refresh authoritative quota in real-time
      if (mounted) {
        context.read<QuotaBloc>().add(const FetchQuotaEvent());
      }

      await claimResult.fold(
        (failure) async {
          if (mounted) {
            final isQuotaOrPayment = failure.message.toLowerCase().contains('quota') ||
                failure.message.toLowerCase().contains('credit') ||
                failure.message.toLowerCase().contains('payment') ||
                failure.message.toLowerCase().contains('removals') ||
                failure.code == 'QUOTA_EXHAUSTED';

            if (isQuotaOrPayment) {
              await WatchAdPromptSheet.show(
                context,
                onRewardGranted: () {
                  _claimAndSave(canvasState);
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.errorRose,
                  content: Text(failure.message),
                ),
              );
            }
          }
        },
        (claimedJob) async {
          String? filePathToSave;

          if (canvasState.mode == BackdropMode.transparent) {
            // Download lossless clean PNG from server
            final cleanUrl = claimedJob.cleanOutputUrl ?? _job!.previewUrl;
            if (cleanUrl != null) {
              final dio = sl<ApiClient>().dio;
              final tempPath = '${Directory.systemTemp.path}/clean_${_job!.id}.png';
              await dio.download(cleanUrl, tempPath);
              filePathToSave = tempPath;
            }
          } else {
            // Export composited image matching exact canvas aspect ratio
            filePathToSave = await _exportCompositeImage(canvasState);
          }

          if (filePathToSave != null) {
            final saved = await GallerySaverService.saveFileToGallery(filePathToSave);
            if (saved && mounted) {
              await HapticService.successPattern();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.successEmerald,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Saved to Camera Roll successfully!'),
                    ],
                  ),
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRose,
            content: Text('Failed to save cutout: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareCutout(StudioCanvasState canvasState) async {
    if (_job == null) return;
    HapticService.light();

    try {
      String? sharePath;
      if (canvasState.mode == BackdropMode.transparent) {
        final targetUrl = _job!.cleanOutputUrl ?? _job!.previewUrl;
        if (targetUrl != null) {
          final dio = sl<ApiClient>().dio;
          final tempPath = '${Directory.systemTemp.path}/share_${_job!.id}.png';
          await dio.download(targetUrl, tempPath);
          sharePath = tempPath;
        }
      } else {
        sharePath = await _exportCompositeImage(canvasState);
      }

      if (sharePath != null) {
        await ShareService.shareImage(sharePath);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Studio Canvas'),
        actions: [
          BlocBuilder<StudioCanvasCubit, StudioCanvasState>(
            builder: (context, canvasState) {
              return IconButton(
                icon: Icon(
                  canvasState.isCompareActive ? Icons.compare_rounded : Icons.visibility_rounded,
                  color: canvasState.isCompareActive ? AppColors.accentCyan : Colors.white,
                ),
                tooltip: 'Toggle Comparison Slider',
                onPressed: () => context.read<StudioCanvasCubit>().toggleCompare(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BlocBuilder<QuotaBloc, QuotaState>(
              builder: (context, quotaState) {
                int remaining = 0;
                bool isPro = false;

                if (quotaState is QuotaLoadedState) {
                  remaining = quotaState.quota.remaining;
                  isPro = quotaState.quota.isPro;
                } else if (quotaState is QuotaExhaustedState) {
                  remaining = 0;
                  isPro = false;
                }

                return QuotaPillBadge(
                  remaining: remaining,
                  isPro: isPro,
                  onTap: () => context.push(RouteNames.paywall),
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.errorRose),
                  ),
                )
              : _buildCanvasEditor(context),
    );
  }

  Widget _buildCanvasEditor(BuildContext context) {
    final previewUrl = _job?.previewUrl ?? '';
    if (previewUrl.isNotEmpty && _imageAspectRatio == null) {
      _resolveAspectRatioFromNetwork(previewUrl);
    }
    final effectiveAspectRatio = _imageAspectRatio ?? 1.0;

    return BlocBuilder<StudioCanvasCubit, StudioCanvasState>(
      builder: (context, canvasState) {
        return Column(
          children: [
            // 1. Zoomable Comparison Studio Canvas constrained to exact Image Aspect Ratio
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                child: ZoomableCanvas(
                  child: AspectRatio(
                    aspectRatio: effectiveAspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceBorder.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: RepaintBoundary(
                        key: _canvasRepaintKey,
                        child: canvasState.isCompareActive && widget.originalFile != null
                            ? ComparisonSlider(
                                originalImage: Image.file(
                                  widget.originalFile!,
                                  fit: BoxFit.cover,
                                ),
                                processedImage: _buildCutoutWithBackdrop(previewUrl, canvasState),
                              )
                            : _buildCutoutWithBackdrop(previewUrl, canvasState),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Backdrop Selector Strip
            BackdropSelectorBar(
              currentState: canvasState,
              onSelectTransparent: () =>
                  context.read<StudioCanvasCubit>().setTransparentMode(),
              onSelectColor: (color) =>
                  context.read<StudioCanvasCubit>().setSolidColor(color),
              onSelectGradient: (gradient) =>
                  context.read<StudioCanvasCubit>().setGradient(gradient),
              onSelectBlur: () =>
                  context.read<StudioCanvasCubit>().setBlurMode(),
              onSelectCustomPhoto: (file) =>
                  context.read<StudioCanvasCubit>().setCustomPhoto(file),
            ),

            // 3. Bottom Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: AppColors.surfaceDark,
              child: Row(
                children: [
                  // Share Button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceBorder,
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: _isSaving ? null : () => _shareCutout(canvasState),
                  ),
                  const SizedBox(width: 12),

                  // Primary Save Button
                  Expanded(
                    child: GlowButton(
                      label: canvasState.mode == BackdropMode.transparent
                          ? 'Save Clean PNG (HD)'
                          : 'Save Studio Image (HD)',
                      icon: Icons.download_rounded,
                      isLoading: _isSaving,
                      onPressed: () => _claimAndSave(canvasState),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCutoutWithBackdrop(String previewUrl, StudioCanvasState canvasState) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // A. Dynamic Backdrop Layer
        if (canvasState.mode == BackdropMode.transparent)
          const CheckerboardBackground()
        else if (canvasState.mode == BackdropMode.solid)
          Container(color: canvasState.solidColor)
        else if (canvasState.mode == BackdropMode.gradient)
          Container(
            decoration: BoxDecoration(gradient: canvasState.gradient),
          )
        else if (canvasState.mode == BackdropMode.customPhoto && canvasState.customPhotoFile != null)
          Image.file(
            canvasState.customPhotoFile!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        else if (canvasState.mode == BackdropMode.blur && widget.originalFile != null)
          ClipRect(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: canvasState.blurSigma,
                sigmaY: canvasState.blurSigma,
                tileMode: TileMode.clamp,
              ),
              child: Image.file(
                widget.originalFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

        // B. Cutout Subject Layer
        if (previewUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: previewUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.broken_image_rounded, color: AppColors.errorRose, size: 48),
            ),
          ),
      ],
    );
  }
}
