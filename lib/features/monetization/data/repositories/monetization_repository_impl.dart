import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/data/datasources/revenuecat_data_source.dart';
import 'package:removeit_app/features/monetization/domain/entities/subscription_package_entity.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';

class MonetizationRepositoryImpl implements MonetizationRepository {
  final RevenueCatDataSource revenueCatDataSource;

  MonetizationRepositoryImpl(this.revenueCatDataSource);

  @override
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getOfferings() async {
    try {
      final offerings = await revenueCatDataSource.getOfferings();
      return Right(offerings);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load subscription offerings: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePackage(String packageId) async {
    try {
      final success = await revenueCatDataSource.purchasePackage(packageId);
      if (success) {
        return const Right(true);
      } else {
        return const Left(ServerFailure(message: 'Purchase was not completed or cancelled.'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Purchase failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final success = await revenueCatDataSource.restorePurchases();
      if (success) {
        return const Right(true);
      } else {
        return const Left(ServerFailure(message: 'No active Pro subscription found to restore.'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore purchases: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkProStatus() async {
    try {
      final isPro = await revenueCatDataSource.isUserPro();
      return Right(isPro);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check pro status: $e'));
    }
  }
}
