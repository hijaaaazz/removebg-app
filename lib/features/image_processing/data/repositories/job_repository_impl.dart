import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/error_handler.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/image_processing/data/datasources/job_remote_data_source.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';
import 'package:removeit_app/features/image_processing/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, JobEntity>> uploadImage(
    File file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final job = await remoteDataSource.uploadImage(file, onProgress: onProgress);
      return Right(job);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobStatus(String jobId) async {
    try {
      final job = await remoteDataSource.getJobStatus(jobId);
      return Right(job);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> claimJob(String jobId) async {
    try {
      final job = await remoteDataSource.claimJob(jobId);
      return Right(job);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
