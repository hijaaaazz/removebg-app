import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/authentication/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
