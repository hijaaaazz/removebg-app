import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_state.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/injection_container.dart';

class ProPaywallScreen extends StatelessWidget {
  const ProPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MonetizationBloc>()..add(const LoadOfferingsEvent()),
      child: const _ProPaywallScreenContent(),
    );
  }
}

class _ProPaywallScreenContent extends StatelessWidget {
  const _ProPaywallScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MonetizationBloc, MonetizationState>(
      listener: (context, state) {
        if (state is MonetizationSuccessState) {
          HapticService.successPattern();
          context.read<QuotaBloc>().add(const FetchQuotaEvent());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.successEmerald,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
            ),
          );
          Navigator.of(context).pop();
        } else if (state is MonetizationErrorState) {
          HapticService.warningPattern();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.errorRose,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        return StudioScaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              TextButton(
                onPressed: state is MonetizationPurchasingState
                    ? null
                    : () {
                        HapticService.selection();
                        context.read<MonetizationBloc>().add(const RestorePurchasesEvent());
                      },
                child: const Text(
                  'Restore',
                  style: TextStyle(
                    color: AppColors.proGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                      Icons.workspace_premium_rounded,
                      color: AppColors.proGold,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'REMOVEIT PRO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.proGold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Unlock Unlimited Studio Power',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Export original sensor quality with zero watermark or daily limits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: const Column(
                    children: [
                      _ProFeatureRow(
                        icon: Icons.all_inclusive_rounded,
                        title: 'Unlimited HD Cutouts',
                        subtitle: 'No daily limits or wait times',
                      ),
                      Divider(color: AppColors.surfaceBorder, height: 20),
                      _ProFeatureRow(
                        icon: Icons.hd_rounded,
                        title: 'Full 4K Native Resolution',
                        subtitle: 'Uncompressed raw sensor quality',
                      ),
                      Divider(color: AppColors.surfaceBorder, height: 20),
                      _ProFeatureRow(
                        icon: Icons.palette_rounded,
                        title: 'Pro Studio Backdrops & Blur',
                        subtitle: 'DSLR bokeh and high-end studio lighting',
                      ),
                      Divider(color: AppColors.surfaceBorder, height: 20),
                      _ProFeatureRow(
                        icon: Icons.block_rounded,
                        title: '100% Ad-Free Studio',
                        subtitle: 'Zero full-screen or rewarded ads',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription Packages
                if (state is MonetizationLoadingState)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.proGold),
                    ),
                  )
                else if (state is MonetizationLoadedState ||
                    state is MonetizationPurchasingState ||
                    state is MonetizationErrorState) ...[
                  ..._buildPackageCards(context, state),
                ],
                const SizedBox(height: 20),

                // CTA Button
                _buildCtaButton(context, state),
                const SizedBox(height: 12),

                // Store Compliance & Legal Links
                const Text(
                  'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in App Store or Google Play settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Legal terms link
                      },
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                    ),
                    const Text('•', style: TextStyle(color: AppColors.textMutedDark)),
                    TextButton(
                      onPressed: () {
                        // Privacy policy link
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPackageCards(BuildContext context, MonetizationState state) {
    List<SubscriptionPackageEntity> packages = [];
    String selectedId = '';

    if (state is MonetizationLoadedState) {
      packages = state.packages;
      selectedId = state.selectedPackageId;
    } else if (state is MonetizationPurchasingState) {
      packages = state.packages;
      selectedId = state.selectedPackageId;
    } else if (state is MonetizationErrorState && state.packages != null) {
      packages = state.packages!;
      selectedId = state.selectedPackageId ?? '';
    }

    return packages.map((pkg) {
      final isSelected = pkg.id == selectedId;
      return GestureDetector(
        onTap: () {
          HapticService.selection();
          context.read<MonetizationBloc>().add(SelectPackageEvent(pkg.id));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.proGold.withValues(alpha: 0.1) : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.proGold : AppColors.surfaceBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.proGold : AppColors.textMutedDark,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.proGold : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: AppColors.backgroundDark)
                    : null,
              ),
              const SizedBox(width: 14),

              // Title & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pkg.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (pkg.isBestValue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.proGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (pkg.trialPeriod != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${pkg.trialPeriod} Free Trial included',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accentCyanLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pkg.priceString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (pkg.monthlyEquivalentPrice != null)
                    Text(
                      pkg.monthlyEquivalentPrice!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCtaButton(BuildContext context, MonetizationState state) {
    final isPurchasing = state is MonetizationPurchasingState;
    String selectedId = '';
    String? trialPeriod;

    if (state is MonetizationLoadedState) {
      selectedId = state.selectedPackageId;
      trialPeriod = state.selectedPackage?.trialPeriod;
    } else if (state is MonetizationPurchasingState) {
      selectedId = state.selectedPackageId;
    }

    final buttonLabel = trialPeriod != null
        ? 'Start 3-Day Free Trial'
        : 'Upgrade to PRO Unlimited';

    return GlowButton(
      label: buttonLabel,
      icon: Icons.bolt_rounded,
      variant: GlowButtonVariant.proGold,
      isLoading: isPurchasing,
      onPressed: isPurchasing || selectedId.isEmpty
          ? null
          : () {
              HapticService.light();
              context.read<MonetizationBloc>().add(PurchaseSelectedPackageEvent(selectedId));
            },
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.proGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.proGold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
