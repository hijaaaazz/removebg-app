import 'package:removeit_app/features/authentication/domain/entities/auth_tokens_entity.dart';

class AuthTokensModel extends AuthTokensEntity {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresInSeconds,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String? ?? '',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'expires_in_seconds': expiresInSeconds,
    };
  }
}
