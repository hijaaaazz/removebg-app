import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retry_count'] as int?) ?? 0;

    // Retry only on network timeouts or 502/503/504 server gateway drops
    final shouldRetry = (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.response != null && err.response!.statusCode! >= 502 && err.response!.statusCode! <= 504)) &&
        retryCount < maxRetries &&
        err.requestOptions.method == 'GET'; // Idempotent methods only

    if (shouldRetry) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;
      await Future<void>.delayed(retryDelay * (retryCount + 1));

      try {
        final dio = Dio();
        final response = await dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
