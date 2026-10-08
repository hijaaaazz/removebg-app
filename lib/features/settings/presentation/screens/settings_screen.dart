import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/buttons/glow_button.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:removeit_app/features/authentication/presentation/widgets/sign_in_prompt_sheet.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _exportFormat = 'PNG';
  String _resolutionMode = 'Original';
  bool _hapticEnabled = true;

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        title: const Text('Studio Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. Account & Membership Card
          _buildAccountSection(context),
          const SizedBox(height: 24),

          // 2. Pro Upgrade Banner (if not pro)
          _buildProBanner(context),
          const SizedBox(height: 24),

          // 3. Studio Engine Preferences
          _buildSectionHeader('STUDIO ENGINE PREFERENCES'),
          const SizedBox(height: 12),
          _buildPreferencesCard(),
          const SizedBox(height: 24),

          // 4. Storage & Cache Maintenance
          _buildSectionHeader('STORAGE & MAINTENANCE'),
          const SizedBox(height: 12),
          _buildStorageCard(context),
          const SizedBox(height: 24),

          // 5. About & Legal
          _buildSectionHeader('ABOUT & LEGAL'),
          const SizedBox(height: 12),
          _buildAboutCard(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMutedDark,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuth = authState is AuthAuthenticatedState;
        final user = isAuth
            ? authState.user
            : (authState is AuthGuestState ? authState.user : null);

        final email = user?.email ?? 'Guest Session';
        final name = user?.displayName ?? 'Studio Creator';

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryViolet,
                      AppColors.accentCyan,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAuth)
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.errorRose),
                  tooltip: 'Sign Out',
                  onPressed: () {
                    HapticService.selection();
                    context.read<AuthBloc>().add(const SignOutEvent());
                  },
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primaryViolet, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => SignInPromptSheet.show(context),
                  child: const Text('Sign In', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProBanner(BuildContext context) {
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

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Default Export Format', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(_exportFormat == 'PNG' ? 'PNG (Transparent Studio Alpha)' : 'JPEG (Solid White)',
                style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            trailing: DropdownButton<String>(
              value: _exportFormat,
              dropdownColor: AppColors.surfaceDark,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'PNG', child: Text('PNG', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'JPEG', child: Text('JPEG', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'WebP', child: Text('WebP', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _exportFormat = val);
              },
            ),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          ListTile(
            title: const Text('Output Resolution Tier', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(_resolutionMode == 'Original' ? 'Original Sensor Quality (Up to 4K)' : 'Web Optimized (1080p)',
                style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            trailing: DropdownButton<String>(
              value: _resolutionMode,
              dropdownColor: AppColors.surfaceDark,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Original', child: Text('Original', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'Web', child: Text('1080p', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _resolutionMode = val);
              },
            ),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          SwitchListTile(
            title: const Text('Haptic Ticks & Feedback', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Subtle touch sensations during slider wipes and button taps',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            activeThumbColor: AppColors.primaryVioletLight,
            activeTrackColor: AppColors.primaryViolet.withValues(alpha: 0.5),
            value: _hapticEnabled,
            onChanged: (val) {
              setState(() => _hapticEnabled = val);
              if (val) HapticService.selection();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.accentCyan),
            title: const Text('Clear Image Cache', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Frees temporary download space without affecting saved photos',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            onTap: () {
              HapticService.selection();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryViolet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: const Text('Cache cleared! 42.4 MB freed.'),
                ),
              );
            },
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.errorRose),
            title: const Text('Clear All Local History', style: TextStyle(color: AppColors.errorRose, fontSize: 14)),
            subtitle: const Text('Purges all saved cutout history from SQLite database',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            onTap: () {
              HapticService.warningPattern();
              showDialog<void>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppColors.surfaceDark,
                  title: const Text('Clear All History?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'This will remove all saved cutouts from your local history.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMutedDark)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRose),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        context.read<HistoryBloc>().add(const DeleteSelectedItemsEvent());
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Column(
        children: [
          const ListTile(
            title: Text('App Version', style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: Text('1.0.0 (Build 1)', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          ListTile(
            title: const Text('Open Source Licenses', style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedDark),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
