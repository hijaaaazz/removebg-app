import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:removeit_app/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String idToken) {
    return repository.signInWithGoogle(idToken);
  }
}
