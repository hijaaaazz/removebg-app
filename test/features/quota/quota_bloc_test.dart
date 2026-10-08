import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:removeit_app/core/error/failures.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';
import 'package:removeit_app/features/quota/domain/repositories/quota_repository.dart';
import 'package:removeit_app/features/quota/domain/usecases/get_user_quota_usecase.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_bloc.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class MockQuotaRepository implements QuotaRepository {
  Either<Failure, UserQuotaEntity>? result;

  @override
  Future<Either<Failure, UserQuotaEntity>> getUserQuota() async {
    return result ??
        const Right(
          UserQuotaEntity(
            plan: 'free',
            baseLimit: 3,
            adBonusGranted: 0,
            totalAllowed: 3,
            used: 1,
            remaining: 2,
            bonusAdsRemainingToday: 2,
          ),
        );
  }
}

void main() {
  late MockQuotaRepository mockRepository;
  late GetUserQuotaUseCase getUserQuotaUseCase;
  late QuotaBloc quotaBloc;

  setUp(() {
    mockRepository = MockQuotaRepository();
    getUserQuotaUseCase = GetUserQuotaUseCase(mockRepository);
    quotaBloc = QuotaBloc(getUserQuotaUseCase: getUserQuotaUseCase);
  });

  tearDown(() {
    quotaBloc.close();
  });

  test('initial state should be QuotaInitialState', () {
    expect(quotaBloc.state, equals(const QuotaInitialState()));
  });

  test('emits [QuotaLoadingState, QuotaLoadedState] when fetch succeeds with remaining quota', () async {
    const expectedQuota = UserQuotaEntity(
      plan: 'free',
      baseLimit: 3,
      adBonusGranted: 0,
      totalAllowed: 3,
      used: 1,
      remaining: 2,
      bonusAdsRemainingToday: 2,
    );
    mockRepository.result = const Right(expectedQuota);

    final expectedStates = [
      const QuotaLoadingState(),
      const QuotaLoadedState(expectedQuota),
    ];

    final expectation = expectLater(quotaBloc.stream, emitsInOrder(expectedStates));

    quotaBloc.add(const FetchQuotaEvent());
    await expectation;
  });

  test('emits [QuotaLoadingState, QuotaExhaustedState] when quota is 0', () async {
    const exhaustedQuota = UserQuotaEntity(
      plan: 'free',
      baseLimit: 3,
      adBonusGranted: 0,
      totalAllowed: 3,
      used: 3,
      remaining: 0,
      bonusAdsRemainingToday: 1,
    );
    mockRepository.result = const Right(exhaustedQuota);

    final expectedStates = [
      const QuotaLoadingState(),
      const QuotaExhaustedState(quota: exhaustedQuota, canWatchBonusAd: true),
    ];

    final expectation = expectLater(quotaBloc.stream, emitsInOrder(expectedStates));

    quotaBloc.add(const FetchQuotaEvent());
    await expectation;
  });
}
