import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';

abstract class QuotaRepository {
  Future<Either<Failure, UserQuotaEntity>> getUserQuota();
}
