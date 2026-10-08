import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

enum GlowButtonVariant { primaryViolet, accentCyan, proGold }

class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final GlowButtonVariant variant;

  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = GlowButtonVariant.primaryViolet,
  });

  @override
  Widget build(BuildContext context) {
    final (baseColor, glowColor) = switch (variant) {
      GlowButtonVariant.primaryViolet => (AppColors.primaryViolet, const Color(0x667C3AED)),
      GlowButtonVariant.accentCyan => (AppColors.accentCyan, const Color(0x6606B6D4)),
      GlowButtonVariant.proGold => (AppColors.proGold, const Color(0x66F59E0B)),
    };

    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null || isLoading
            ? []
            : [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColor,
          disabledBackgroundColor: baseColor.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: isLoading || onPressed == null
            ? null
            : () {
                HapticService.light();
                onPressed!();
              },
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                ],
              ),
      ),
    );
  }
}
