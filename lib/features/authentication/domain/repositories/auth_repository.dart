import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle(String idToken);
  Future<Either<Failure, UserEntity>> initializeGuestSession();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
}
