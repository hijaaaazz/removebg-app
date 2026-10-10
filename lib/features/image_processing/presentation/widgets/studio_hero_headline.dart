import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class StudioHeroHeadline extends StatelessWidget {
  const StudioHeroHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start with Photo,',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const Text(
          'Remove Background',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Text(
              'Using ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldAccent],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0C0C0E),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(' 🔥', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Remove Background Instantly',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.goldLight,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Sub-pixel hairline segmentation powered by BiRefNet AI.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}
