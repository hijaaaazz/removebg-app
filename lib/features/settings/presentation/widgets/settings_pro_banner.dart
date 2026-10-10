import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class SettingsProBanner extends StatelessWidget {
  const SettingsProBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotaBloc, QuotaState>(
      builder: (context, quotaState) {
        final isPro = quotaState is QuotaLoadedState && quotaState.quota.isPro;
        if (isPro) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.proGold.withValues(alpha: 0.2),
                  AppColors.surfaceDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.proGold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppColors.proGold, size: 28),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO UNLIMITED ACTIVE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.proGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Full 4K sensor quality & unlimited HD cuts',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.proGold.withValues(alpha: 0.15),
                AppColors.primaryViolet.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.proGold.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.proGold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'RemoveIt PRO Studio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock unlimited HD removals, full 4K exports, DSLR blur effects, and 100% ad-free workflow.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.3),
              ),
              const SizedBox(height: 16),
              GlowButton(
                label: 'Upgrade to PRO Unlimited',
                icon: Icons.workspace_premium_rounded,
                variant: GlowButtonVariant.proGold,
                onPressed: () => context.push(RouteNames.paywall),
              ),
            ],
          ),
        );
      },
    );
  }
}
