import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:removeit_app/features/quota/domain/usecases/get_user_quota_usecase.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_event.dart';
import 'package:removeit_app/features/quota/presentation/bloc/quota_state.dart';

class QuotaBloc extends Bloc<QuotaEvent, QuotaState> {
  final GetUserQuotaUseCase getUserQuotaUseCase;

  QuotaBloc({required this.getUserQuotaUseCase}) : super(const QuotaInitialState()) {
    on<FetchQuotaEvent>(_onFetchQuota);
    on<QuotaDecrementedEvent>(_onQuotaDecremented);
    on<AdBonusRewardedEvent>(_onAdBonusRewarded);
  }

  Future<void> _onFetchQuota(FetchQuotaEvent event, Emitter<QuotaState> emit) async {
    emit(const QuotaLoadingState());
    final result = await getUserQuotaUseCase();

    result.fold(
      (failure) => emit(QuotaErrorState(failure.message)),
      (quota) {
        if (!quota.hasQuota) {
          emit(QuotaExhaustedState(quota: quota, canWatchBonusAd: quota.canWatchBonusAd));
        } else {
          emit(QuotaLoadedState(quota));
        }
      },
    );
  }

  Future<void> _onQuotaDecremented(QuotaDecrementedEvent event, Emitter<QuotaState> emit) async {
    // Re-fetch quota from backend to guarantee server-authoritative numbers
    add(const FetchQuotaEvent());
  }

  Future<void> _onAdBonusRewarded(AdBonusRewardedEvent event, Emitter<QuotaState> emit) async {
    // Re-fetch quota after SSV server verification
    add(const FetchQuotaEvent());
  }
}
