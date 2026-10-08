import 'package:equatable/equatable.dart';

class UserQuotaEntity extends Equatable {
  final String plan;
  final int baseLimit;
  final int adBonusGranted;
  final int totalAllowed;
  final int used;
  final int remaining;
  final int bonusAdsRemainingToday;
  final DateTime? resetsAt;

  const UserQuotaEntity({
    required this.plan,
    required this.baseLimit,
    required this.adBonusGranted,
    required this.totalAllowed,
    required this.used,
    required this.remaining,
    required this.bonusAdsRemainingToday,
    this.resetsAt,
  });

  bool get isPro => plan.toLowerCase().contains('pro');
  bool get hasQuota => remaining > 0 || isPro;
  bool get canWatchBonusAd => !isPro && bonusAdsRemainingToday > 0;

  @override
  List<Object?> get props => [
        plan,
        baseLimit,
        adBonusGranted,
        totalAllowed,
        used,
        remaining,
        bonusAdsRemainingToday,
        resetsAt,
      ];
}
