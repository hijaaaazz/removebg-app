import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class JobProcessingEvent extends Equatable {
  const JobProcessingEvent();
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends JobProcessingEvent {
  final File file;
  const PickImageEvent(this.file);
  @override
  List<Object?> get props => [file];
}

class UploadProgressUpdatedEvent extends JobProcessingEvent {
  final double progress;
  const UploadProgressUpdatedEvent(this.progress);
  @override
  List<Object?> get props => [progress];
}

class ClaimCleanJobEvent extends JobProcessingEvent {
  final String jobId;
  const ClaimCleanJobEvent(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class ResetJobEvent extends JobProcessingEvent {
  const ResetJobEvent();
}
