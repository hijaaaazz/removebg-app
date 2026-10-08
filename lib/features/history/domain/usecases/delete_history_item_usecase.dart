import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/history/domain/repositories/history_repository.dart';

class DeleteHistoryItemUseCase {
  final HistoryRepository repository;

  DeleteHistoryItemUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteJob(id);
  }
}
