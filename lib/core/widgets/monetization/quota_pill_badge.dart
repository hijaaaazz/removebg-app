import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class QuotaPillBadge extends StatelessWidget {
  final int remaining;
  final bool isPro;
  final VoidCallback onTap;

  const QuotaPillBadge({
    super.key,
    required this.remaining,
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
          color: isPro ? AppColors.proGold.withValues(alpha: 0.15) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPro ? AppColors.proGold.withValues(alpha: 0.4) : AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPro ? Icons.workspace_premium_rounded : Icons.flash_on_rounded,
              color: isPro ? AppColors.proGold : (remaining > 0 ? AppColors.accentCyan : AppColors.warningAmber),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isPro ? 'PRO' : '$remaining Left',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPro ? AppColors.proGold : (remaining > 0 ? Colors.white : AppColors.warningAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
