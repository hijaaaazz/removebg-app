import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/services/image_picker_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/utils/context_extensions.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/core/widgets/monetization/quota_exhausted_sheet.dart';
import 'package:removeit_app/core/widgets/monetization/quota_pill_badge.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_bloc.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_event.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_state.dart';
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

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  Future<void> _pickImage(BuildContext context, ImagePickerSource source) async {
    final quotaState = context.read<QuotaBloc>().state;
    if (quotaState is QuotaExhaustedState ||
        (quotaState is QuotaLoadedState && !quotaState.quota.hasQuota)) {
      final canWatch = (quotaState is QuotaExhaustedState)
          ? quotaState.canWatchBonusAd
          : (quotaState as QuotaLoadedState).quota.canWatchBonusAd;
      await QuotaExhaustedSheet.show(context, canWatchBonusAd: canWatch);
      return;
    }

    HapticService.light();
    final picker = sl<ImagePickerService>();
    final file = await picker.pickImage(source);
    if (file != null && context.mounted) {
      context.read<JobProcessingBloc>().add(PickImageEvent(file));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('RemoveIt Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BlocBuilder<QuotaBloc, QuotaState>(
              builder: (context, quotaState) {
                int remaining = 0;
                bool isPro = false;
                bool canWatchBonus = true;

                if (quotaState is QuotaLoadedState) {
                  remaining = quotaState.quota.remaining;
                  isPro = quotaState.quota.isPro;
                  canWatchBonus = quotaState.quota.canWatchBonusAd;
                } else if (quotaState is QuotaExhaustedState) {
                  remaining = 0;
                  isPro = false;
                  canWatchBonus = quotaState.canWatchBonusAd;
                }

                return QuotaPillBadge(
                  remaining: remaining,
                  isPro: isPro,
                  onTap: () {
                    if (isPro) return;
                    if (remaining <= 0) {
                      QuotaExhaustedSheet.show(context, canWatchBonusAd: canWatchBonus);
                    } else {
                      context.push(RouteNames.paywall);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<JobProcessingBloc, JobProcessingState>(
        listener: (context, state) {
          if (state is JobPreviewReadyState) {
            HapticService.successPattern();
            context.read<QuotaBloc>().add(const QuotaDecrementedEvent());
            context.push(
              '${RouteNames.canvas}?jobId=${state.job.id}',
              extra: state.originalFile,
            );
          } else if (state is JobErrorState) {
            HapticService.warningPattern();
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
        },
        builder: (context, state) {
          final isProcessing = state is JobCompressingState ||
              state is JobUploadingState ||
              state is JobProcessingOnServerState;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Dropzone Hero or Processing State
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isProcessing ? AppColors.accentCyan : AppColors.surfaceBorder,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isProcessing ? AppColors.accentCyan : AppColors.primaryViolet)
                            .withValues(alpha: 0.12),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isProcessing
                        ? _buildProcessingView(state)
                        : _buildUploadIdleView(context),
                  ),
                ),
                const Spacer(),

                // Action Buttons
                GlowButton(
                  label: 'Select Photo from Gallery',
                  icon: Icons.photo_library_rounded,
                  isLoading: isProcessing,
                  onPressed: isProcessing
                      ? null
                      : () => _pickImage(context, ImagePickerSource.gallery),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isProcessing
                      ? null
                      : () => _pickImage(context, ImagePickerSource.camera),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.textSecondaryDark),
                      SizedBox(width: 8),
                      Text(
                        'Take Photo with Camera',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadIdleView(BuildContext context) {
    return Column(
      key: const ValueKey('idle_view'),
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryViolet.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.primaryViolet.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.primaryVioletLight,
            size: 38,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Remove Background Instantly',
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Select any portrait or product photo to isolate subjects with studio precision.',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProcessingView(JobProcessingState state) {
    String title = 'Processing Image...';
    String subtitle = 'Isolating subjects with BiRefNet AI';
    double? progressValue;

    if (state is JobCompressingState) {
      title = 'Optimizing Photo...';
      subtitle = 'Downscaling and stripping metadata off-thread';
    } else if (state is JobUploadingState) {
      title = 'Uploading Image...';
      subtitle = 'Sending bytes to inference worker';
      progressValue = state.progress;
    } else if (state is JobProcessingOnServerState) {
      title = 'Removing Background...';
      subtitle = 'BiRefNet neural network is segmenting the subject';
    }

    return Column(
      key: const ValueKey('processing_view'),
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: progressValue,
            strokeWidth: 3,
            color: AppColors.accentCyan,
            backgroundColor: AppColors.surfaceBorder,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
