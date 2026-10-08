import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/core/network/auth_interceptor.dart';
import 'package:removeit_app/core/network/logging_interceptor.dart';
import 'package:removeit_app/core/network/network_info.dart';
import 'package:removeit_app/core/network/retry_interceptor.dart';
import 'package:removeit_app/core/services/image_picker_service.dart';
import 'package:removeit_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:removeit_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:removeit_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:removeit_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:removeit_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/initialize_guest_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:removeit_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:removeit_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:removeit_app/features/image_processing/data/datasources/job_remote_data_source.dart';
import 'package:removeit_app/features/image_processing/data/repositories/job_repository_impl.dart';
import 'package:removeit_app/features/image_processing/domain/repositories/job_repository.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/claim_job_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/poll_job_status_usecase.dart';
import 'package:removeit_app/features/image_processing/domain/usecases/upload_image_usecase.dart';
import 'package:removeit_app/features/image_processing/presentation/bloc/job_processing_bloc.dart';
import 'package:removeit_app/features/monetization/data/datasources/admob_data_source.dart';
import 'package:removeit_app/features/monetization/data/datasources/revenuecat_data_source.dart';
import 'package:removeit_app/features/monetization/data/repositories/monetization_repository_impl.dart';
import 'package:removeit_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:removeit_app/features/monetization/domain/usecases/check_pro_status_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/get_offerings_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/purchase_package_usecase.dart';
import 'package:removeit_app/features/monetization/domain/usecases/restore_purchases_usecase.dart';
import 'package:removeit_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:removeit_app/features/quota/data/datasources/quota_remote_data_source.dart';
import 'package:removeit_app/features/quota/data/repositories/quota_repository_impl.dart';
import 'package:removeit_app/features/quota/domain/repositories/quota_repository.dart';
import 'package:removeit_app/features/quota/domain/usecases/get_user_quota_usecase.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // 1. External Drivers
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // 2. Core Network & Services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(
        dio: Dio(),
        secureStorage: sl(),
      ));
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  sl.registerLazySingleton<RetryInterceptor>(() => RetryInterceptor());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        authInterceptor: sl(),
        loggingInterceptor: sl(),
        retryInterceptor: sl(),
      ));
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerService());

  // 3. Authentication Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
        secureStorage: sl(),
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));
  sl.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton<InitializeGuestUseCase>(() => InitializeGuestUseCase(sl()));
  sl.registerLazySingleton<SignInWithGoogleUseCase>(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(
        getCurrentUserUseCase: sl(),
        initializeGuestUseCase: sl(),
        signInWithGoogleUseCase: sl(),
        signOutUseCase: sl(),
      ));

  // 4. Image Processing Feature
  sl.registerLazySingleton<JobRemoteDataSource>(() => JobRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl(sl()));
  sl.registerLazySingleton<UploadImageUseCase>(() => UploadImageUseCase(sl()));
  sl.registerLazySingleton<PollJobStatusUseCase>(() => PollJobStatusUseCase(sl()));
  sl.registerLazySingleton<ClaimJobUseCase>(() => ClaimJobUseCase(sl()));
  sl.registerFactory<JobProcessingBloc>(() => JobProcessingBloc(
        uploadImageUseCase: sl(),
        pollJobStatusUseCase: sl(),
        claimJobUseCase: sl(),
      ));

  // 5. Quota & AdMob Monetization Feature
  sl.registerLazySingleton<QuotaRemoteDataSource>(() => QuotaRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<QuotaRepository>(() => QuotaRepositoryImpl(sl()));
  sl.registerLazySingleton<GetUserQuotaUseCase>(() => GetUserQuotaUseCase(sl()));
  sl.registerLazySingleton<QuotaBloc>(() => QuotaBloc(getUserQuotaUseCase: sl()));
  sl.registerLazySingleton<AdMobDataSource>(() => AdMobDataSourceImpl(sl()));

  // 6. RevenueCat In-App Purchases Feature
  sl.registerLazySingleton<RevenueCatDataSource>(() => RevenueCatDataSourceImpl());
  sl.registerLazySingleton<MonetizationRepository>(() => MonetizationRepositoryImpl(sl()));
  sl.registerLazySingleton<GetOfferingsUseCase>(() => GetOfferingsUseCase(sl()));
  sl.registerLazySingleton<PurchasePackageUseCase>(() => PurchasePackageUseCase(sl()));
  sl.registerLazySingleton<RestorePurchasesUseCase>(() => RestorePurchasesUseCase(sl()));
  sl.registerLazySingleton<CheckProStatusUseCase>(() => CheckProStatusUseCase(sl()));
  sl.registerFactory<MonetizationBloc>(() => MonetizationBloc(
        getOfferingsUseCase: sl(),
        purchasePackageUseCase: sl(),
        restorePurchasesUseCase: sl(),
        checkProStatusUseCase: sl(),
      ));
}
