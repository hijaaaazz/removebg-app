import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:removeit_app/core/error/error_handler.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/core/services/google_auth_service.dart';
import 'package:removeit_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:removeit_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:removeit_app/features/authentication/data/models/user_model.dart';
import 'package:removeit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:removeit_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GoogleAuthService googleAuthService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.googleAuthService,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle(String idToken) async {
    try {
      final result = await remoteDataSource.signInWithGoogle(idToken);
      await localDataSource.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      await localDataSource.saveUser(result.user);
      return Right(result.user);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> initializeGuestSession() async {
    try {
      final cached = await localDataSource.getCachedUser();
      if (cached != null) {
        return Right(cached);
      }

      final deviceUuid = await localDataSource.getOrCreateDeviceUuid();
      final guestUser = UserModel(
        id: deviceUuid,
        email: '',
        displayName: 'Guest Creator',
        planCode: 'free',
        isGuest: true,
      );
      await localDataSource.saveUser(guestUser);
      return Right(guestUser);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to initialize guest session: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve cached user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await googleAuthService.signOut();
      await localDataSource.clearAuthSession();
      // Re-initialize guest user so the app remains fully functional
      await initializeGuestSession();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to sign out: $e'));
    }
  }
}
