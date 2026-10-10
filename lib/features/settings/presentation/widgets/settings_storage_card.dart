import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';
import 'package:removeit_app/injection_container.dart';

class SettingsStorageCard extends StatelessWidget {
  const SettingsStorageCard({super.key});

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
            leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.accentCyan),
            title: const Text('Clear Image Cache', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text(
              'Frees temporary download space without affecting saved photos',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
            onTap: () {
              HapticService.selection();
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryViolet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: const Text('Cache cleared! Space freed.'),
                ),
              );
            },
          ),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.errorRose),
            title: const Text('Clear All Local History', style: TextStyle(color: AppColors.errorRose, fontSize: 14)),
            subtitle: const Text(
              'Purges all saved cutout history from SQLite database',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
            onTap: () {
              HapticService.warningPattern();
              showDialog<void>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppColors.surfaceDark,
                  title: const Text('Clear All History?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'This will remove all saved cutouts from your local history database.',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMutedDark)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRose),
                      onPressed: () async {
                        Navigator.of(dialogCtx).pop();
                        await sl<HistoryRepository>().clearAllHistory();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primaryViolet,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: const Text('History database cleared.'),
                            ),
                          );
                        }
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
}
