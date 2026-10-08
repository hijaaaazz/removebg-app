import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class QuotaPillBadge extends StatelessWidget {
  final int remaining;
  final bool isPro;
  final VoidCallback onTap;

  const QuotaPillBadge({
    super.key,
    this.remaining = 0,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPro
              ? AppColors.proGold.withValues(alpha: 0.15)
              : AppColors.primaryViolet.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPro
                ? AppColors.proGold.withValues(alpha: 0.5)
                : AppColors.proGold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.proGold,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isPro ? 'PRO' : 'Go Pro',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.proGold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
