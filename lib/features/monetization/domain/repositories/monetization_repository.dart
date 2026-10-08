import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';

abstract class MonetizationRepository {
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getOfferings();
  Future<Either<Failure, bool>> purchasePackage(String packageId);
  Future<Either<Failure, bool>> restorePurchases();
  Future<Either<Failure, bool>> checkProStatus();
}
