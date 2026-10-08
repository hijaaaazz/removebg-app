import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';

class PurchasePackageUseCase {
  final MonetizationRepository repository;

  PurchasePackageUseCase(this.repository);

  Future<Either<Failure, bool>> call(String packageId) {
    return repository.purchasePackage(packageId);
  }
}
