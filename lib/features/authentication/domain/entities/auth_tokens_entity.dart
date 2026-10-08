import 'package:equatable/equatable.dart';

class AuthTokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresInSeconds];
}
