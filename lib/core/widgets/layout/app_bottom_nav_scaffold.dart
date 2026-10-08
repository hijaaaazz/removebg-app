import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class AppBottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    if (index != navigationShell.currentIndex) {
      HapticService.selection();
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primaryViolet.withValues(alpha: 0.2),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_fix_high_outlined, color: AppColors.textSecondaryDark),
              selectedIcon: Icon(Icons.auto_fix_high_rounded, color: AppColors.primaryVioletLight),
              label: 'Studio',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, color: AppColors.textSecondaryDark),
              selectedIcon: Icon(Icons.history_rounded, color: AppColors.primaryVioletLight),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.textSecondaryDark),
              selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryVioletLight),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
