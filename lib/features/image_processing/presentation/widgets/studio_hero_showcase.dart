import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/canvas/checkerboard_background.dart';
import 'package:removeit_app/features/image_processing/presentation/widgets/viewfinder_corner_painter.dart';

class StudioHeroShowcase extends StatelessWidget {
  final Animation<double> scanAnimation;
  final VoidCallback onTap;

  const StudioHeroShowcase({
    super.key,
    required this.scanAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.studioCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.studioBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Background Checkerboard for Cutout Half
                const CheckerboardBackground(squareSize: 10),

                // Showcase Graphic / Subject Demo
                AnimatedBuilder(
                  animation: scanAnimation,
                  builder: (context, _) {
                    final scanProgress = scanAnimation.value;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Base Warm Studio Subject Silhouette / Mockup
                        Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(0, -0.2),
                              radius: 0.8,
                              colors: [
                                Color(0xFF382312),
                                Color(0xFF16161A),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: cardHeight * 0.45,
                              color: AppColors.goldPrimary.withValues(alpha: 0.22),
                            ),
                          ),
                        ),

                        // Top Revealing Checkerboard Cutout Mask (Above Scan Line)
                        ClipRect(
                          clipper: VerticalScanClipRect(scanProgress),
                          child: const Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned(top: 35, left: 45, child: Icon(Icons.star_rounded, size: 16, color: AppColors.goldPrimary)),
                              Positioned(top: 55, right: 60, child: Icon(Icons.star_rounded, size: 18, color: AppColors.goldPrimary)),
                              Positioned(top: 90, left: 90, child: Icon(Icons.star_rounded, size: 14, color: AppColors.goldLight)),
                              Positioned(top: 110, right: 110, child: Icon(Icons.star_rounded, size: 16, color: AppColors.goldPrimary)),
                            ],
                          ),
                        ),

                        // Glowing Golden Laser Scan Line
                        Positioned(
                          top: (scanProgress * (cardHeight - 6)).clamp(0.0, cardHeight),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Camera Viewfinder Brackets [ ] Overlay
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CustomPaint(
                    painter: ViewfinderCornerPainter(
                      color: AppColors.goldPrimary,
                      cornerLength: 26,
                      strokeWidth: 3,
                    ),
                  ),
                ),

                // Bottom Right Golden Sparkles Floating Badge
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF0C0C0E),
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Tap Hint Pill Chip
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 14, color: AppColors.goldPrimary),
                        SizedBox(width: 6),
                        Text(
                          'Tap to Choose Photo',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
