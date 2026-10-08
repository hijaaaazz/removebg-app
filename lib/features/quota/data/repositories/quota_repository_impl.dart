import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/error_handler.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/quota/data/datasources/quota_remote_data_source.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';
import 'package:removeit_app/features/quota/domain/repositories/quota_repository.dart';

class QuotaRepositoryImpl implements QuotaRepository {
  final QuotaRemoteDataSource remoteDataSource;

  QuotaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserQuotaEntity>> getUserQuota() async {
    try {
      final quota = await remoteDataSource.getUserQuota();
      return Right(quota);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
