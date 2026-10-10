import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/monetization/quota_pill_badge.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class StudioHeader extends StatelessWidget {
  const StudioHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo Emblem
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_fix_high_rounded,
                  size: 20,
                  color: Color(0xFF0C0C0E),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'RemoveIt Studio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Right Actions: Quota Pill & Settings Navigation Button
        Row(
          children: [
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
            const SizedBox(width: 10),
            // Settings Icon Button (Navigates to Settings Screen)
            GestureDetector(
              onTap: () {
                HapticService.selection();
                context.push(RouteNames.settings);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.studioCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.studioBorder, width: 1.2),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
