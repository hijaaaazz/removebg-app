import 'package:drift/drift.dart';

class JobHistoryTable extends Table {
  TextColumn get id => text()();
  TextColumn get originalLocalPath => text().nullable()();
  TextColumn get previewRemoteUrl => text()();
  TextColumn get cleanRemoteUrl => text().nullable()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
