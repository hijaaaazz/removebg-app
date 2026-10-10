import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/services/image_picker_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:removeit_app/features/authentication/presentation/widgets/sign_in_prompt_sheet.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_bloc.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_event.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_state.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/image_source_picker_sheet.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/studio_header.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/studio_hero_headline.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/studio_hero_showcase.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/studio_interactive_scanner.dart';
import 'package:removeit_app/features/monetization/data/datasources/admob_data_source.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';
import 'package:removeit_app/injection_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobProcessingBloc>(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with SingleTickerProviderStateMixin {
  bool _isPickingImage = false;
  File? _selectedFile;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    // Preload rewarded ad in the background for instantaneous display
    sl<AdMobDataSource>().preloadRewardedAd();

    // Controller for the animated scan line effect
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    // Don't run infinite animation in widget test environment to allow pumpAndSettle
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _scanController.repeat(reverse: true);
    } else {
      _scanController.value = 0.5;
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImagePickerSource source) async {
    HapticService.light();
    setState(() => _isPickingImage = true);
    File? file;
    try {
      final picker = sl<ImagePickerService>();
      file = await picker.pickImage(source);
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
    if (file == null || !context.mounted) return;
    final selectedFile = file;
    setState(() => _selectedFile = selectedFile);

    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticatedState;

    if (isAuthenticated) {
      await _processImageWithAdCheck(context, selectedFile);
    } else {
      // Show prompt after image is selected: sign in with Google to continue
      await SignInPromptSheet.show(
        context,
        onSignInSuccess: () {
          if (context.mounted) {
            _processImageWithAdCheck(context, selectedFile);
          }
        },
      );
    }
  }

  Future<void> _processImageWithAdCheck(BuildContext context, File file) async {
    final quotaState = context.read<QuotaBloc>().state;
    final isPro = (quotaState is QuotaLoadedState) && quotaState.quota.isPro;

    if (isPro) {
      // Pro subscribers get instant processing with zero ads
      context.read<JobProcessingBloc>().add(PickImageEvent(file));
      return;
    }

    // Free users: Forcefully play rewarded ad right after selecting image
    final authState = context.read<AuthBloc>().state;
    final userId = (authState is AuthAuthenticatedState)
        ? authState.user.id
        : (authState is AuthGuestState ? authState.user.id : 'anonymous_guest');

    await sl<AdMobDataSource>().showRewardedBonusAd(
      userId: userId,
      onRewardGranted: () {
        if (!context.mounted) return;
        context.read<QuotaBloc>().add(const AdBonusRewardedEvent());
        // Reward was earned -> proceed with server processing
        context.read<JobProcessingBloc>().add(PickImageEvent(file));
      },
      onAdCancelled: () {
        if (!context.mounted) return;
        setState(() => _selectedFile = null);
        // User closed/cancelled the ad early: DO NOT CALL SERVER!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceBorder,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.accentCyan),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Video was closed before finishing. No cut was used.'),
                ),
              ],
            ),
          ),
        );
      },
      onFailure: (error) {
        if (!context.mounted) return;
        // If ad inventory fails or device is offline, proceed gracefully
        context.read<JobProcessingBloc>().add(PickImageEvent(file));
      },
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    ImageSourcePickerSheet.show(
      context,
      onSourceSelected: (source) => _pickImage(context, source),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      body: BlocConsumer<JobProcessingBloc, JobProcessingState>(
        listener: (context, state) async {
          if (state is JobPreviewReadyState) {
            await HapticService.successPattern();
            if (!context.mounted) return;
            context.read<QuotaBloc>().add(const QuotaDecrementedEvent());
            await context.push(
              '${RouteNames.canvas}?jobId=${state.job.id}',
              extra: state.originalFile,
            );
            if (context.mounted) {
              setState(() => _selectedFile = null);
              context.read<JobProcessingBloc>().add(const ResetJobEvent());
            }
          } else if (state is JobErrorState) {
            await HapticService.warningPattern();
            setState(() => _selectedFile = null);
            if (!context.mounted) return;
            if (state.errorCode == 'UNAUTHENTICATED') {
              unawaited(SignInPromptSheet.show(context));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.errorRose,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(state.message, style: const TextStyle(color: Colors.white)),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<JobProcessingBloc>().add(const ResetJobEvent());
                    },
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isProcessing = state is JobCompressingState ||
              state is JobUploadingState ||
              state is JobProcessingOnServerState;

          if (isProcessing) {
            return StudioInteractiveScanner(
              selectedFile: _selectedFile,
              scanAnimation: _scanController,
              state: state,
              onCancel: () {
                setState(() => _selectedFile = null);
                context.read<JobProcessingBloc>().add(const ResetJobEvent());
              },
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const StudioHeader(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: StudioHeroShowcase(
                      scanAnimation: _scanController,
                      onTap: () => _showImageSourcePicker(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const StudioHeroHeadline(),
                  const SizedBox(height: 16),
                  GlowButton(
                    label: 'Start with Photo',
                    icon: Icons.add_photo_alternate_rounded,
                    variant: GlowButtonVariant.proGold,
                    borderRadius: 28,
                    isLoading: _isPickingImage,
                    onPressed: () => _showImageSourcePicker(context),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
