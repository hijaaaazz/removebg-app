import 'package:drift/drift.dart';
import 'package:removeit_app/core/database/app_database.dart';

abstract class HistoryLocalDataSource {
  Stream<List<JobHistoryTableData>> watchHistory();
  Future<List<JobHistoryTableData>> getAllHistory();
  Future<void> insertOrUpdateJob(JobHistoryTableCompanion job);
  Future<void> deleteJob(String id);
  Future<void> bulkDeleteJobs(List<String> ids);
  Future<void> clearAllHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final AppDatabase db;

  HistoryLocalDataSourceImpl(this.db);

  @override
  Stream<List<JobHistoryTableData>> watchHistory() {
    return (db.select(db.jobHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  @override
  Future<List<JobHistoryTableData>> getAllHistory() {
    return (db.select(db.jobHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<void> insertOrUpdateJob(JobHistoryTableCompanion job) {
    return db.into(db.jobHistoryTable).insertOnConflictUpdate(job);
  }

  @override
  Future<void> deleteJob(String id) {
    return (db.delete(db.jobHistoryTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> bulkDeleteJobs(List<String> ids) {
    return (db.delete(db.jobHistoryTable)..where((t) => t.id.isIn(ids))).go();
  }

  @override
  Future<void> clearAllHistory() {
    return db.delete(db.jobHistoryTable).go();
  }
}
