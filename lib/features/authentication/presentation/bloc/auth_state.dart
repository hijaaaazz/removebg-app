import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthGuestState extends AuthState {
  final UserEntity user;
  const AuthGuestState(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthAuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthAuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
