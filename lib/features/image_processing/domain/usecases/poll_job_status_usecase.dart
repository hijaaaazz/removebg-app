import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/repositories/job_repository.dart';

class PollJobStatusUseCase {
  final JobRepository repository;

  PollJobStatusUseCase(this.repository);

  Future<Either<Failure, JobEntity>> call(String jobId) {
    return repository.getJobStatus(jobId);
  }
}
