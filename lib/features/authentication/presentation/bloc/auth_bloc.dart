import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/initialize_guest_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final InitializeGuestUseCase initializeGuestUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.initializeGuestUseCase,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
  }) : super(const AuthInitialState()) {
    on<AppStartedAuthEvent>(_onAppStarted);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onAppStarted(AppStartedAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    final result = await getCurrentUserUseCase();

    await result.fold(
      (failure) async {
        // Fallback to guest initialization
        final guestResult = await initializeGuestUseCase();
        guestResult.fold(
          (guestFail) => emit(AuthErrorState(guestFail.message)),
          (guestUser) => emit(AuthGuestState(guestUser)),
        );
      },
      (user) async {
        if (user != null) {
          if (user.isGuest) {
            emit(AuthGuestState(user));
          } else {
            emit(AuthAuthenticatedState(user));
          }
        } else {
          final guestResult = await initializeGuestUseCase();
          guestResult.fold(
            (guestFail) => emit(AuthErrorState(guestFail.message)),
            (guestUser) => emit(AuthGuestState(guestUser)),
          );
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    final result = await signInWithGoogleUseCase(event.idToken);
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (user) => emit(AuthAuthenticatedState(user)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    await signOutUseCase();
    final guestResult = await initializeGuestUseCase();
    guestResult.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (guestUser) => emit(AuthGuestState(guestUser)),
    );
  }
}
