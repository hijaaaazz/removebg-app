import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';
import 'package:removeit_app/features/quota/domain/repositories/quota_repository.dart';

class GetUserQuotaUseCase {
  final QuotaRepository repository;

  GetUserQuotaUseCase(this.repository);

  Future<Either<Failure, UserQuotaEntity>> call() {
    return repository.getUserQuota();
  }
}
