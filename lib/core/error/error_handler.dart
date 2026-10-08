import 'package:dio/dio.dart';
import 'package:removeit_app/core/error/failures.dart';

class ErrorHandler {
  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['error'] != null) {
          final errorObj = data['error'];
          final code = errorObj['code'] as String?;
          
          String message = 'An unexpected error occurred.';
          if (errorObj['user_friendly_message'] is String && (errorObj['user_friendly_message'] as String).isNotEmpty) {
            message = errorObj['user_friendly_message'] as String;
          } else if (errorObj['message'] is String && (errorObj['message'] as String).isNotEmpty) {
            message = errorObj['message'] as String;
          } else if (errorObj['message'] is Map) {
            final msgMap = errorObj['message'] as Map;
            message = msgMap['detail']?.toString() ?? msgMap.values.firstOrNull?.toString() ?? message;
          } else if (errorObj['details'] is Map) {
            final detailsMap = errorObj['details'] as Map;
            message = detailsMap['detail']?.toString() ?? detailsMap.values.firstOrNull?.toString() ?? message;
          }

          switch (code) {
            case 'UNAUTHENTICATED':
              return UnauthenticatedFailure(message: message);
            case 'QUOTA_EXHAUSTED':
              return const QuotaExhaustedFailure();
            case 'MAX_AD_BONUSES_REACHED':
              return const MaxAdBonusesReachedFailure();
            case 'INVALID_IMAGE':
              return const InvalidImageFailure();
            case 'IMAGE_TOO_LARGE':
              return const ImageTooLargeFailure();
            case 'INFERENCE_FAILED':
              return const InferenceFailure();
            case 'MAINTENANCE_MODE':
              return const MaintenanceModeFailure();
            default:
              return ServerFailure(message: message, code: code);
          }
        }
        if (error.response?.statusCode == 401) {
          return const UnauthenticatedFailure();
        }
        return ServerFailure(
          message: 'Server error: ${error.response?.statusCode}',
          code: 'SERVER_${error.response?.statusCode}',
        );

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Request was cancelled.');

      default:
        return const NetworkFailure();
    }
  }
}
