import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/constants/storage_keys.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.dio, required this.secureStorage});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        return handler.next(err);
      }

      try {
        // Isolated Dio to avoid recursive interceptor loops
        final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
        final response = await refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.authRefresh,
          data: {'refresh': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final raw = response.data!;
          final data = (raw['data'] is Map<String, dynamic>)
              ? raw['data'] as Map<String, dynamic>
              : raw;
          final newAccessToken = data['access'] as String?;
          final newRefreshToken = data['refresh'] as String?;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await secureStorage.write(key: StorageKeys.accessToken, value: newAccessToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await secureStorage.write(key: StorageKeys.refreshToken, value: newRefreshToken);
            }

            // Retry failed request with new access token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch<dynamic>(options);
            return handler.resolve(retryResponse);
          }
        }
      } catch (refreshError) {
        // Token revoked/expired: purge stored credentials
        await secureStorage.delete(key: StorageKeys.accessToken);
        await secureStorage.delete(key: StorageKeys.refreshToken);
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
