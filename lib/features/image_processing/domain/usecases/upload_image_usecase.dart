import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/repositories/job_repository.dart';

class UploadImageParams {
  final File file;
  final void Function(int sent, int total)? onProgress;

  const UploadImageParams({required this.file, this.onProgress});
}

class UploadImageUseCase {
  final JobRepository repository;

  UploadImageUseCase(this.repository);

  Future<Either<Failure, JobEntity>> call(UploadImageParams params) {
    return repository.uploadImage(params.file, onProgress: params.onProgress);
  }
}
