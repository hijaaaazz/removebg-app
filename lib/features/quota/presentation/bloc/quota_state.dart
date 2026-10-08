import 'package:equatable/equatable.dart';
import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';

abstract class QuotaState extends Equatable {
  const QuotaState();
  @override
  List<Object?> get props => [];
}

class QuotaInitialState extends QuotaState {
  const QuotaInitialState();
}

class QuotaLoadingState extends QuotaState {
  const QuotaLoadingState();
}

class QuotaLoadedState extends QuotaState {
  final UserQuotaEntity quota;
  const QuotaLoadedState(this.quota);
  @override
  List<Object?> get props => [quota];
}

class QuotaExhaustedState extends QuotaState {
  final UserQuotaEntity quota;
  final bool canWatchBonusAd;
  const QuotaExhaustedState({required this.quota, required this.canWatchBonusAd});
  @override
  List<Object?> get props => [quota, canWatchBonusAd];
}

class QuotaErrorState extends QuotaState {
  final String message;
  const QuotaErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
