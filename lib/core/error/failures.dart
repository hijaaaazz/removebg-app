import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure({
    super.message = 'Please sign in with your Google account to continue.',
    super.code = 'UNAUTHENTICATED',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection detected. Please check your network.',
    super.code = 'NETWORK_UNAVAILABLE',
  });
}

class QuotaExhaustedFailure extends Failure {
  const QuotaExhaustedFailure({
    super.message = "You have used today's free removals! Watch a quick video to unlock a bonus or switch to Pro.",
    super.code = 'QUOTA_EXHAUSTED',
  });
}

class MaxAdBonusesReachedFailure extends Failure {
  const MaxAdBonusesReachedFailure({
    super.message =
        'You have claimed all bonus removals for today! Upgrade to Pro for unlimited removals.',
    super.code = 'MAX_AD_BONUSES_REACHED',
  });
}

class InvalidImageFailure extends Failure {
  const InvalidImageFailure({
    super.message = 'This photo format is not supported. Please choose a JPG, PNG, or WebP photo.',
    super.code = 'INVALID_IMAGE',
  });
}

class ImageTooLargeFailure extends Failure {
  const ImageTooLargeFailure({
    super.message = 'The photo file is too large (max 25MB). Please choose a smaller photo.',
    super.code = 'IMAGE_TOO_LARGE',
  });
}

class InferenceFailure extends Failure {
  const InferenceFailure({
    super.message = 'Something went wrong while removing the background. Your daily quota was not deducted. Please try again!',
    super.code = 'INFERENCE_FAILED',
  });
}

class MaintenanceModeFailure extends Failure {
  const MaintenanceModeFailure({
    super.message = "We're doing a quick system update to improve quality! We'll be back online in just a few minutes.",
    super.code = 'MAINTENANCE_MODE',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load local cached data.',
    super.code = 'CACHE_ERROR',
  });
}
