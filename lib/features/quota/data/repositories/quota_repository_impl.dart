import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/error_handler.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/monetization/data/datasources/revenuecat_data_source.dart';
import 'package:removeit_app/features/quota/data/datasources/quota_remote_data_source.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';
import 'package:removeit_app/features/quota/domain/repositories/quota_repository.dart';

class QuotaRepositoryImpl implements QuotaRepository {
  final QuotaRemoteDataSource remoteDataSource;
  final RevenueCatDataSource revenueCatDataSource;

  QuotaRepositoryImpl(this.remoteDataSource, this.revenueCatDataSource);

  @override
  Future<Either<Failure, UserQuotaEntity>> getUserQuota() async {
    try {
      final quota = await remoteDataSource.getUserQuota();
      final isPro = await revenueCatDataSource.isUserPro();
      if (isPro) {
        return Right(quota.copyWith(plan: 'pro'));
      }
      return Right(quota);
    } on DioException catch (e) {
      final isPro = await revenueCatDataSource.isUserPro();
      if (isPro) {
        return const Right(UserQuotaEntity(
          plan: 'pro',
          baseLimit: 9999,
          adBonusGranted: 0,
          totalAllowed: 9999,
          used: 0,
          remaining: 9999,
          bonusAdsRemainingToday: 0,
        ));
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      final isPro = await revenueCatDataSource.isUserPro();
      if (isPro) {
        return const Right(UserQuotaEntity(
          plan: 'pro',
          baseLimit: 9999,
          adBonusGranted: 0,
          totalAllowed: 9999,
          used: 0,
          remaining: 9999,
          bonusAdsRemainingToday: 0,
        ));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
