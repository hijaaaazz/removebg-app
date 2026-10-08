import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

abstract class HistoryRepository {
  Stream<List<HistoryItemEntity>> watchHistory();
  Future<Either<Failure, Unit>> syncHistory();
  Future<Either<Failure, Unit>> deleteJob(String id);
  Future<Either<Failure, Unit>> bulkDeleteJobs(List<String> ids);
  Future<Either<Failure, Unit>> clearAllHistory();
  Future<void> saveJobToHistory(JobEntity job, {String? originalLocalPath});
}
