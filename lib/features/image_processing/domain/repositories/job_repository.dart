import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

abstract class JobRepository {
  Future<Either<Failure, JobEntity>> uploadImage(
    File file, {
    void Function(int sent, int total)? onProgress,
  });

  Future<Either<Failure, JobEntity>> getJobStatus(String jobId);

  Future<Either<Failure, JobEntity>> claimJob(String jobId);
}
