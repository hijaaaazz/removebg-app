import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';

class BulkDeleteHistoryItemsUseCase {
  final HistoryRepository repository;

  BulkDeleteHistoryItemsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(List<String> ids) {
    return repository.bulkDeleteJobs(ids);
  }
}
