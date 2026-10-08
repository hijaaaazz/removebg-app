import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/core/constants/app_constants.dart';
import 'package:removeit_app/core/utils/image_preprocessor.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/claim_job_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/poll_job_status_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/upload_image_usecase.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_event.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_state.dart';

class JobProcessingBloc extends Bloc<JobProcessingEvent, JobProcessingState> {
  final UploadImageUseCase uploadImageUseCase;
  final PollJobStatusUseCase pollJobStatusUseCase;
  final ClaimJobUseCase claimJobUseCase;

  File? _lastOriginalFile;

  JobProcessingBloc({
    required this.uploadImageUseCase,
    required this.pollJobStatusUseCase,
    required this.claimJobUseCase,
  }) : super(const JobInitialState()) {
    on<PickImageEvent>(_onPickImage);
    on<UploadProgressUpdatedEvent>(_onUploadProgress);
    on<ClaimCleanJobEvent>(_onClaimCleanJob);
    on<ResetJobEvent>(_onResetJob);
  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<JobProcessingState> emit) async {
    _lastOriginalFile = event.file;
    emit(const JobCompressingState());

    try {
      // 1. Isolate image preprocessor
      final optimized = await ImagePreprocessor.prepareForUpload(event.file);

      // 2. Upload to backend with progress
      emit(const JobUploadingState(0.0));
      final uploadResult = await uploadImageUseCase(
        UploadImageParams(
          file: optimized,
          onProgress: (sent, total) {
            if (total > 0) {
              add(UploadProgressUpdatedEvent(sent / total));
            }
          },
        ),
      );

      await uploadResult.fold(
        (failure) async {
          emit(JobErrorState(message: failure.message, errorCode: failure.code));
        },
        (job) async {
          // 3. Asynchronous job polling loop
          emit(JobProcessingOnServerState(
            jobId: job.id,
            estimatedSecondsRemaining: job.estimatedWaitSeconds,
          ));

          await Future<void>.delayed(AppConstants.pollInitialDelay);

          bool pollFinished = false;
          for (int attempt = 0; attempt < AppConstants.maxPollAttempts; attempt++) {
            if (pollFinished) break;

            final pollResult = await pollJobStatusUseCase(job.id);
            await pollResult.fold(
              (failure) async {
                pollFinished = true;
                emit(JobErrorState(message: failure.message, errorCode: failure.code));
              },
              (currentJob) async {
                if (currentJob.isPreviewReady) {
                  pollFinished = true;
                  emit(JobPreviewReadyState(
                    job: currentJob,
                    originalFile: _lastOriginalFile ?? event.file,
                  ));
                } else if (currentJob.isCompleted) {
                  pollFinished = true;
                  emit(JobCompletedState(
                    job: currentJob,
                    originalFile: _lastOriginalFile ?? event.file,
                  ));
                } else if (currentJob.isFailed) {
                  pollFinished = true;
                  emit(const JobErrorState(
                    message: 'Background removal could not isolate subject.',
                    errorCode: 'INFERENCE_FAILED',
                  ));
                } else {
                  // Still running
                  await Future<void>.delayed(AppConstants.pollInterval);
                }
              },
            );
          }

          if (!pollFinished && state is JobProcessingOnServerState) {
            emit(const JobErrorState(
              message: 'Processing timed out. Please try again.',
              errorCode: 'PROCESSING_TIMEOUT',
            ));
          }
        },
      );
    } catch (e) {
      emit(JobErrorState(message: 'Failed to process image: $e'));
    }
  }

  void _onUploadProgress(UploadProgressUpdatedEvent event, Emitter<JobProcessingState> emit) {
    if (state is JobUploadingState) {
      emit(JobUploadingState(event.progress));
    }
  }

  Future<void> _onClaimCleanJob(ClaimCleanJobEvent event, Emitter<JobProcessingState> emit) async {
    emit(JobClaimingState(event.jobId));
    final result = await claimJobUseCase(event.jobId);

    result.fold(
      (failure) => emit(JobErrorState(message: failure.message, errorCode: failure.code)),
      (cleanJob) => emit(JobCompletedState(
        job: cleanJob,
        originalFile: _lastOriginalFile ?? File(''),
      )),
    );
  }

  void _onResetJob(ResetJobEvent event, Emitter<JobProcessingState> emit) {
    _lastOriginalFile = null;
    emit(const JobInitialState());
  }
}
