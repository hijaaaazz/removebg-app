import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';

class CheckProStatusUseCase {
  final MonetizationRepository repository;

  CheckProStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.checkProStatus();
  }
}
