import 'dart:io';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/authentication/data/models/auth_tokens_model.dart';
import 'package:removeit_app/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, AuthTokensModel tokens})> signInWithGoogle(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<({UserModel user, AuthTokensModel tokens})> signInWithGoogle(String idToken) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authGoogle,
      data: {
        'id_token': idToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      },
    );

    final raw = response.data!;
    final data = (raw['data'] is Map<String, dynamic>)
        ? raw['data'] as Map<String, dynamic>
        : raw;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens = AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>);

    return (user: user, tokens: tokens);
  }
}
