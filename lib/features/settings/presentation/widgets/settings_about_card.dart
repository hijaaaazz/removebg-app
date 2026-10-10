import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class SettingsAboutCard extends StatelessWidget {
  const SettingsAboutCard({super.key});

  @override
  Widget build(BuildContext context) {
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
