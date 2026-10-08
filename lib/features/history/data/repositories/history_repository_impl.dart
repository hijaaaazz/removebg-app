import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/database/app_database.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/data/datasources/history_local_data_source.dart';
import 'package:removeit_app/features/history/data/datasources/history_remote_data_source.dart';
import 'package:removeit_app/features/history/domain/entities/history_item_entity.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';
import 'package:removeit_app/features/image_processing/domain/entities/job_entity.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Stream<List<HistoryItemEntity>> watchHistory() {
    return localDataSource.watchHistory().map((tableDataList) {
      return tableDataList.map(_mapTableDataToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, Unit>> syncHistory() async {
    try {
      final remoteJobs = await remoteDataSource.fetchRemoteHistory();

      for (final job in remoteJobs) {
        if (job.previewUrl != null) {
          await localDataSource.insertOrUpdateJob(
            JobHistoryTableCompanion(
              id: Value(job.id),
              previewRemoteUrl: Value(job.previewUrl!),
              cleanRemoteUrl: Value(job.cleanOutputUrl),
              width: Value(job.width ?? 1080),
              height: Value(job.height ?? 1080),
              createdAt: Value(DateTime.now()),
              isSynced: const Value(true),
            ),
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      // In offline mode or sync failure, keep rendering local SQLite data
      return Left(ServerFailure(message: 'Offline mode active: Sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJob(String id) async {
    try {
      await localDataSource.deleteJob(id);
      try {
        await remoteDataSource.deleteRemoteJob(id);
      } catch (_) {
        // Silently tolerate if offline; local record is deleted
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete cutout: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> bulkDeleteJobs(List<String> ids) async {
    try {
      await localDataSource.bulkDeleteJobs(ids);
      try {
        await remoteDataSource.bulkDeleteRemoteJobs(ids);
      } catch (_) {
        // Silently tolerate if offline
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to bulk delete cutouts: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllHistory() async {
    try {
      await localDataSource.clearAllHistory();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to clear history: $e'));
    }
  }

  @override
  Future<void> saveJobToHistory(JobEntity job, {String? originalLocalPath}) async {
    if (job.previewUrl == null) return;
    try {
      await localDataSource.insertOrUpdateJob(
        JobHistoryTableCompanion(
          id: Value(job.id),
          originalLocalPath: Value(originalLocalPath),
          previewRemoteUrl: Value(job.previewUrl!),
          cleanRemoteUrl: Value(job.cleanOutputUrl),
          width: Value(job.width ?? 1080),
          height: Value(job.height ?? 1080),
          createdAt: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
      );
    } catch (_) {}
  }

  HistoryItemEntity _mapTableDataToEntity(JobHistoryTableData data) {
    return HistoryItemEntity(
      id: data.id,
      originalLocalPath: data.originalLocalPath,
      previewRemoteUrl: data.previewRemoteUrl,
      cleanRemoteUrl: data.cleanRemoteUrl,
      width: data.width,
      height: data.height,
      createdAt: data.createdAt,
      isPro: data.isPro,
      isSynced: data.isSynced,
    );
  }
}
