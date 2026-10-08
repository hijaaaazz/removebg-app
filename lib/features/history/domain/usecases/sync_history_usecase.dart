import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';

class SyncHistoryUseCase {
  final HistoryRepository repository;

  SyncHistoryUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.syncHistory();
  }
}
