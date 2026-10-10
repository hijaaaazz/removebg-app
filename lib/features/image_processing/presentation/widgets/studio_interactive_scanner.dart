import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/canvas/checkerboard_background.dart';
import 'package:removeit_app/core/widgets/monetization/quota_pill_badge.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_state.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/viewfinder_corner_painter.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class StudioInteractiveScanner extends StatelessWidget {
  final File? selectedFile;
  final Animation<double> scanAnimation;
  final JobProcessingState state;
  final VoidCallback onCancel;

  const StudioInteractiveScanner({
    super.key,
    required this.selectedFile,
    required this.scanAnimation,
    required this.state,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    String stepTitle = 'Removing Background...';
    String stepSubtitle = 'BiRefNet AI neural engine is segmenting the subject.';
    double? progress;

    final currentState = state;
    if (currentState is JobCompressingState) {
      stepTitle = 'Optimizing Photo...';
      stepSubtitle = 'Downscaling and stripping metadata off-thread.';
    } else if (currentState is JobUploadingState) {
      stepTitle = 'Uploading to Studio...';
      stepSubtitle = 'Sending image bytes to inference worker.';
      progress = currentState.progress;
    } else if (currentState is JobProcessingOnServerState) {
      stepTitle = 'Isolating Edges...';
      stepSubtitle = 'Detecting sub-pixel hairlines and transparency alpha.';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            // Top Bar with Close (X) button & Quota Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    onCancel();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.studioCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.studioBorder, width: 1.2),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
                BlocBuilder<QuotaBloc, QuotaState>(
                  builder: (context, quotaState) {
                    int remaining = 0;
                    bool isPro = false;
                    if (quotaState is QuotaLoadedState) {
                      remaining = quotaState.quota.remaining;
                      isPro = quotaState.quota.isPro;
                    }
                    return QuotaPillBadge(
                      remaining: remaining,
                      isPro: isPro,
                      onTap: () => context.push(RouteNames.paywall),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Rounded Photo Card with Scanning Laser & Checkerboard Reveal
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.studioCard,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.18),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scanHeight = constraints.maxHeight;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // If selected file is present, show it!
                        if (selectedFile != null)
                          Image.file(selectedFile!, fit: BoxFit.cover)
                        else
                          const Center(
                            child: Icon(Icons.photo_rounded, size: 80, color: AppColors.textMutedDark),
                          ),

                        // Animated Scan Line & Top Reveal
                        AnimatedBuilder(
                          animation: scanAnimation,
                          builder: (context, _) {
                            final scanY = (scanAnimation.value * (scanHeight - 6)).clamp(0.0, scanHeight);
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Top Section Revealed as Transparent Checkerboard with Sparkles
                                ClipRect(
                                  clipper: VerticalScanClipRect(scanAnimation.value),
                                  child: const Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CheckerboardBackground(squareSize: 10),
                                      Positioned(top: 35, left: 45, child: Icon(Icons.star_rounded, size: 16, color: AppColors.goldPrimary)),
                                      Positioned(top: 55, right: 60, child: Icon(Icons.star_rounded, size: 18, color: AppColors.goldPrimary)),
                                      Positioned(top: 90, left: 90, child: Icon(Icons.star_rounded, size: 14, color: AppColors.goldLight)),
                                      Positioned(top: 110, right: 110, child: Icon(Icons.star_rounded, size: 16, color: AppColors.goldPrimary)),
                                    ],
                                  ),
                                ),

                                // Glowing Horizontal Gold Scan Line
                                Positioned(
                                  top: scanY,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.goldPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.goldPrimary.withValues(alpha: 0.9),
                                          blurRadius: 14,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Corner Brackets
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CustomPaint(
                            painter: ViewfinderCornerPainter(
                              color: AppColors.goldPrimary,
                              cornerLength: 22,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Progress Indicator & Text
            if (progress != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.studioBorder,
                    color: AppColors.goldPrimary,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              stepTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              stepSubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Cancel / Back Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.studioBorder, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () {
                HapticService.selection();
                onCancel();
              },
              child: const Text('Cancel Processing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
