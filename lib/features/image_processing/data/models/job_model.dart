import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.status,
    super.previewUrl,
    super.cleanOutputUrl,
    super.width,
    super.height,
    super.outputResolutionTier,
    super.isQuotaConsumed = false,
    super.requiresClaim = false,
    super.estimatedWaitSeconds = 3,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    int? w;
    int? h;

    if (json['original_dimensions'] is Map<String, dynamic>) {
      final dims = json['original_dimensions'] as Map<String, dynamic>;
      w = dims['width'] as int?;
      h = dims['height'] as int?;
    } else if (json['resolution'] is Map<String, dynamic>) {
      final res = json['resolution'] as Map<String, dynamic>;
      w = res['width'] as int?;
      h = res['height'] as int?;
    }

    return JobModel(
      id: (json['job_id'] ?? json['id']) as String,
      status: json['status'] as String? ?? 'queued',
      previewUrl: json['preview_url'] as String?,
      cleanOutputUrl: json['clean_output_url'] as String?,
      width: w,
      height: h,
      outputResolutionTier: json['output_resolution_tier'] as String?,
      isQuotaConsumed: json['is_quota_consumed'] as bool? ?? false,
      requiresClaim: json['requires_claim'] as bool? ?? false,
      estimatedWaitSeconds: json['estimated_wait_seconds'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': id,
      'status': status,
      'preview_url': previewUrl,
      'clean_output_url': cleanOutputUrl,
      'original_dimensions': {
        'width': width,
        'height': height,
      },
      'output_resolution_tier': outputResolutionTier,
      'is_quota_consumed': isQuotaConsumed,
      'requires_claim': requiresClaim,
      'estimated_wait_seconds': estimatedWaitSeconds,
    };
  }
}
