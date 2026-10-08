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

class WatchAdPromptSheet extends StatefulWidget {
  final VoidCallback onRewardGranted;

  const WatchAdPromptSheet({
    super.key,
    required this.onRewardGranted,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRewardGranted,
  }) {
    HapticService.light();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WatchAdPromptSheet(onRewardGranted: onRewardGranted),
    );
  }

  @override
  State<WatchAdPromptSheet> createState() => _WatchAdPromptSheetState();
}

class _WatchAdPromptSheetState extends State<WatchAdPromptSheet> {
  bool _isLoadingAd = false;

  Future<void> _watchAd(BuildContext context) async {
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
          widget.onRewardGranted();
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
                    child: Text('Video was closed before finishing. No cut was used.'),
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
              content: Text('Could not play video: $error. Please try again or go Pro.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

            // Hero Badge Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.proGold.withValues(alpha: 0.25),
                      AppColors.primaryViolet.withValues(alpha: 0.25),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.proGold.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.proGold,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Titles
            const Text(
              'Unlock HD Cutout',
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
              'Watch a short video to unlock and save your cutout in HD, or upgrade to Pro for instant, ad-free processing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Primary: Go Pro
            GlowButton(
              label: 'Upgrade to PRO (Instant & Ad-Free)',
              icon: Icons.workspace_premium_rounded,
              variant: GlowButtonVariant.proGold,
              onPressed: () {
                Navigator.of(context).pop();
                context.push(RouteNames.paywall);
              },
            ),
            const SizedBox(height: 12),

            // Secondary: Watch Ad
            OutlinedButton.icon(
              onPressed: _isLoadingAd ? null : () => _watchAd(context),
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
                _isLoadingAd ? 'Loading Video...' : 'Watch Short Video (Free Unlock)',
                style: const TextStyle(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AppColors.accentCyan.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Dismiss
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
