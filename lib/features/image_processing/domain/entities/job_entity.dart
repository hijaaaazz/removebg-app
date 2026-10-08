import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String status;
  final String? previewUrl;
  final String? cleanOutputUrl;
  final int? width;
  final int? height;
  final String? outputResolutionTier;
  final bool isQuotaConsumed;
  final bool requiresClaim;
  final int estimatedWaitSeconds;

  const JobEntity({
    required this.id,
    required this.status,
    this.previewUrl,
    this.cleanOutputUrl,
    this.width,
    this.height,
    this.outputResolutionTier,
    this.isQuotaConsumed = false,
    this.requiresClaim = false,
    this.estimatedWaitSeconds = 3,
  });

  bool get isPreviewReady => status == 'preview_ready';
  bool get isCompleted => status == 'completed';
  bool get isRunning => status == 'running' || status == 'queued';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [
        id,
        status,
        previewUrl,
        cleanOutputUrl,
        width,
        height,
        outputResolutionTier,
        isQuotaConsumed,
        requiresClaim,
        estimatedWaitSeconds,
      ];
}
