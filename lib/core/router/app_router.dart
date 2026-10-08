import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:removeit_app/core/router/route_names.dart';
import 'package:removeit_app/core/widgets/layout/app_bottom_nav_scaffold.dart';
import 'package:removeit_app/features/history/presentation/screens/history_screen.dart';
import 'package:removeit_app/features/image_processing/presentation/screens/home_screen.dart';
import 'package:removeit_app/features/monetization/presentation/screens/pro_paywall_screen.dart';
import 'package:removeit_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:removeit_app/features/studio_canvas/presentation/screens/studio_canvas_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppBottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.canvas,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          final extraFile = state.extra is File ? state.extra as File : null;
          return StudioCanvasScreen(jobId: jobId, originalFile: extraFile);
        },
      ),
      GoRoute(
        path: RouteNames.paywall,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProPaywallScreen(),
      ),
    ],
  );
}
