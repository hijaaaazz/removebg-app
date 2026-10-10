import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class SettingsPreferencesCard extends StatefulWidget {
  const SettingsPreferencesCard({super.key});

  @override
  State<SettingsPreferencesCard> createState() => _SettingsPreferencesCardState();
}

class _SettingsPreferencesCardState extends State<SettingsPreferencesCard> {
  String _exportFormat = 'PNG';
  String _resolutionMode = 'Original';
  bool _hapticEnabled = true;

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
          ListTile(
            title: const Text('Default Export Format', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(
              _exportFormat == 'PNG' ? 'PNG (Transparent Studio Alpha)' : 'JPEG (Solid White)',
              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
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
            subtitle: Text(
              _resolutionMode == 'Original' ? 'Original Sensor Quality (Up to 4K)' : 'Web Optimized (1080p)',
              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
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
            subtitle: const Text(
              'Subtle touch sensations during slider wipes and button taps',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
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
}
