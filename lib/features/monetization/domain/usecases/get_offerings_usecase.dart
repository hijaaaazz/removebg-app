import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';

class GetOfferingsUseCase {
  final MonetizationRepository repository;

  GetOfferingsUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionPackageEntity>>> call() {
    return repository.getOfferings();
  }
}
