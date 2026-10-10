import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/widgets/layout/studio_scaffold.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:removeit_app/features/history/presentation/bloc/history_event.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_about_card.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_account_card.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_history_section.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_preferences_card.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_pro_banner.dart';
import 'package:removeit_app/features/settings/presentation/widgets/settings_storage_card.dart';
import 'package:removeit_app/injection_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const StartWatchHistoryEvent()),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return StudioScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Studio Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: const [
          // 1. Account & Membership Card
          SettingsAccountCard(),
          SizedBox(height: 24),

          // 2. Pro Upgrade Banner (if not pro)
          SettingsProBanner(),
          SizedBox(height: 24),

          // 3. Studio Cutout History Section (Embedded into Settings)
          _SectionHeader('STUDIO CUTOUT HISTORY'),
          SizedBox(height: 12),
          SettingsHistorySection(),
          SizedBox(height: 24),

          // 4. Studio Engine Preferences
          _SectionHeader('STUDIO ENGINE PREFERENCES'),
          SizedBox(height: 12),
          SettingsPreferencesCard(),
          SizedBox(height: 24),

          // 5. Storage & Cache Maintenance
          _SectionHeader('STORAGE & MAINTENANCE'),
          SizedBox(height: 12),
          SettingsStorageCard(),
          SizedBox(height: 24),

          // 6. About & Legal
          _SectionHeader('ABOUT & LEGAL'),
          SizedBox(height: 12),
          SettingsAboutCard(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
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
}
