import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:removeit_app/features/monetization/data/datasources/admob_data_source.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/injection_container.dart';

class QuotaExhaustedSheet extends StatefulWidget {
  final bool canWatchBonusAd;

  const QuotaExhaustedSheet({
    super.key,
    this.canWatchBonusAd = true,
  });

  static Future<void> show(BuildContext context, {bool canWatchBonusAd = true}) {
    HapticService.warningPattern();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuotaExhaustedSheet(canWatchBonusAd: canWatchBonusAd),
    );
  }

  @override
  State<QuotaExhaustedSheet> createState() => _QuotaExhaustedSheetState();
}

class _QuotaExhaustedSheetState extends State<QuotaExhaustedSheet> {
  bool _isLoadingAd = false;

  Future<void> _watchBonusAd(BuildContext context) async {
    setState(() => _isLoadingAd = true);
    HapticService.light();

    final authState = context.read<AuthBloc>().state;
    final userId = (authState is AuthAuthenticatedState)
        ? authState.user.id
        : (authState is AuthGuestState ? authState.user.id : 'anonymous_guest');

    try {
      await sl<AdMobDataSource>().showRewardedBonusAd(
        userId: userId,
        onRewardGranted: () {
          if (!mounted) return;
          context.read<QuotaBloc>().add(const AdBonusRewardedEvent());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryViolet,
              content: const Row(
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.accentCyan),
                  SizedBox(width: 8),
                  Text('+1 Bonus Cut Added!'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        onAdCancelled: () {
          if (!mounted) return;
          setState(() => _isLoadingAd = false);
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
                    child: Text('Video was closed before finishing. No cut was added.'),
                  ),
                ],
              ),
            ),
          );
        },
        onFailure: (error) {
          if (!mounted) return;
          setState(() => _isLoadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.errorRose,
              content: Text('Could not load ad: $error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAd = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textMutedDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warningAmber.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.warningAmber,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Subtitle
            const Text(
              'Daily Limit Reached',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have used all your free cuts for today. Free quota automatically refreshes every night at midnight.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade to Pro Glow Button
            GlowButton(
              label: 'Upgrade to PRO (Unlimited HD)',
              icon: Icons.workspace_premium_rounded,
              variant: GlowButtonVariant.proGold,
              onPressed: () {
                Navigator.of(context).pop();
                context.push(RouteNames.paywall);
              },
            ),
            const SizedBox(height: 12),

            // Bonus Ad option
            if (widget.canWatchBonusAd) ...[
              OutlinedButton.icon(
                onPressed: _isLoadingAd ? null : () => _watchBonusAd(context),
                icon: _isLoadingAd
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentCyan,
                        ),
                      )
                    : const Icon(Icons.play_circle_fill_rounded, color: AppColors.accentCyan),
                label: Text(
                  _isLoadingAd ? 'Loading Ad...' : 'Watch Video (+1 Bonus Cut)',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: AppColors.accentCyan.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  color: AppColors.textMutedDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
