import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStartedAuthEvent extends AuthEvent {
  const AppStartedAuthEvent();
}

class SignInWithGoogleEvent extends AuthEvent {
  final String idToken;
  const SignInWithGoogleEvent(this.idToken);
  @override
  List<Object?> get props => [idToken];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
