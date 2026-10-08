import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

abstract class JobProcessingState extends Equatable {
  const JobProcessingState();
  @override
  List<Object?> get props => [];
}

class JobInitialState extends JobProcessingState {
  const JobInitialState();
}

class JobCompressingState extends JobProcessingState {
  const JobCompressingState();
}

class JobUploadingState extends JobProcessingState {
  final double progress; // 0.0 to 1.0
  const JobUploadingState(this.progress);
  @override
  List<Object?> get props => [progress];
}

class JobProcessingOnServerState extends JobProcessingState {
  final String jobId;
  final int estimatedSecondsRemaining;
  const JobProcessingOnServerState({
    required this.jobId,
    required this.estimatedSecondsRemaining,
  });
  @override
  List<Object?> get props => [jobId, estimatedSecondsRemaining];
}

class JobPreviewReadyState extends JobProcessingState {
  final JobEntity job;
  final File originalFile;
  const JobPreviewReadyState({required this.job, required this.originalFile});
  @override
  List<Object?> get props => [job, originalFile];
}

class JobClaimingState extends JobProcessingState {
  final String jobId;
  const JobClaimingState(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class JobCompletedState extends JobProcessingState {
  final JobEntity job;
  final File originalFile;
  const JobCompletedState({required this.job, required this.originalFile});
  @override
  List<Object?> get props => [job, originalFile];
}

class JobErrorState extends JobProcessingState {
  final String message;
  final String? errorCode;
  const JobErrorState({required this.message, this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}
