import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:removeit_app/features/authentication/domain/repositories/auth_repository.dart';

class InitializeGuestUseCase {
  final AuthRepository repository;

  InitializeGuestUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.initializeGuestSession();
  }
}
