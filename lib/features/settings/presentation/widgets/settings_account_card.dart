import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:removeit_app/features/authentication/presentation/widgets/sign_in_prompt_sheet.dart';
import 'package:removeit_app/features/settings/presentation/widgets/sign_out_confirmation_dialog.dart';

class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () async {
                    final confirmed = await SignOutConfirmationDialog.show(context);
                    if (confirmed == true && context.mounted) {
                      HapticService.selection();
                      context.read<AuthBloc>().add(const SignOutEvent());
                    }
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
}
