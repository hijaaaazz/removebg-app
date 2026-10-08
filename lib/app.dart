import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/core/router/app_router.dart';
import 'package:removeit_app/core/theme/app_theme.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/injection_container.dart';

class RemoveItApp extends StatelessWidget {
  const RemoveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AppStartedAuthEvent()),
        ),
        BlocProvider<QuotaBloc>(
          create: (_) => sl<QuotaBloc>()..add(const FetchQuotaEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: EnvConfig.instance.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
