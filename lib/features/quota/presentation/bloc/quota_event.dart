import 'package:equatable/equatable.dart';

abstract class QuotaEvent extends Equatable {
  const QuotaEvent();
  @override
  List<Object?> get props => [];
}

class FetchQuotaEvent extends QuotaEvent {
  const FetchQuotaEvent();
}

class QuotaDecrementedEvent extends QuotaEvent {
  const QuotaDecrementedEvent();
}

class AdBonusRewardedEvent extends QuotaEvent {
  const AdBonusRewardedEvent();
}
