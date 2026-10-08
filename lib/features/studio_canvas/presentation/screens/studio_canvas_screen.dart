import 'dart:io';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/network/api_client.dart';
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
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/claim_job_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/poll_job_status_usecase.dart';
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

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
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
        }),
      );
    }
  }

  Future<void> _claimAndSave() async {
    if (_job == null) return;
    HapticService.light();
    setState(() => _isSaving = true);

    try {
      final claimUseCase = sl<ClaimJobUseCase>();
      final claimResult = await claimUseCase(_job!.id);

      await claimResult.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.errorRose,
                content: Text(failure.message),
              ),
            );
          }
        },
        (claimedJob) async {
          // Download clean file and save to camera roll
          final cleanUrl = claimedJob.cleanOutputUrl ?? _job!.previewUrl;
          if (cleanUrl != null) {
            final dio = sl<ApiClient>().dio;
            final tempPath = '${Directory.systemTemp.path}/clean_${_job!.id}.png';
            await dio.download(cleanUrl, tempPath);

            final saved = await GallerySaverService.saveFileToGallery(tempPath);
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

  Future<void> _shareCutout() async {
    if (_job == null) return;
    HapticService.light();

    final targetUrl = _job!.cleanOutputUrl ?? _job!.previewUrl;
    if (targetUrl != null) {
      final dio = sl<ApiClient>().dio;
      final tempPath = '${Directory.systemTemp.path}/share_${_job!.id}.png';
      await dio.download(targetUrl, tempPath);
      await ShareService.shareImage(tempPath);
    }
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
            child: QuotaPillBadge(
              remaining: 1,
              isPro: false,
              onTap: () {},
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

    return BlocBuilder<StudioCanvasCubit, StudioCanvasState>(
      builder: (context, canvasState) {
        return Column(
          children: [
            // 1. Zoomable Comparison Studio Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: ZoomableCanvas(
                  child: canvasState.isCompareActive && widget.originalFile != null
                      ? ComparisonSlider(
                          originalImage: Image.file(
                            widget.originalFile!,
                            fit: BoxFit.contain,
                          ),
                          processedImage: _buildCutoutWithBackdrop(previewUrl, canvasState),
                        )
                      : _buildCutoutWithBackdrop(previewUrl, canvasState),
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
                    onPressed: _isSaving ? null : _shareCutout,
                  ),
                  const SizedBox(width: 12),

                  // Primary Save Button
                  Expanded(
                    child: GlowButton(
                      label: 'Save Clean PNG (HD)',
                      icon: Icons.download_rounded,
                      isLoading: _isSaving,
                      onPressed: _claimAndSave,
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
          Image.file(canvasState.customPhotoFile!, fit: BoxFit.cover)
        else if (canvasState.mode == BackdropMode.blur && widget.originalFile != null)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: canvasState.blurSigma,
              sigmaY: canvasState.blurSigma,
            ),
            child: Image.file(widget.originalFile!, fit: BoxFit.contain),
          ),

        // B. Cutout Subject Layer
        if (previewUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: previewUrl,
            fit: BoxFit.contain,
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
