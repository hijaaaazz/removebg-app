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

  UserQuotaEntity copyWith({
    String? plan,
    int? baseLimit,
    int? adBonusGranted,
    int? totalAllowed,
    int? used,
    int? remaining,
    int? bonusAdsRemainingToday,
    DateTime? resetsAt,
  }) {
    return UserQuotaEntity(
      plan: plan ?? this.plan,
      baseLimit: baseLimit ?? this.baseLimit,
      adBonusGranted: adBonusGranted ?? this.adBonusGranted,
      totalAllowed: totalAllowed ?? this.totalAllowed,
      used: used ?? this.used,
      remaining: remaining ?? this.remaining,
      bonusAdsRemainingToday: bonusAdsRemainingToday ?? this.bonusAdsRemainingToday,
      resetsAt: resetsAt ?? this.resetsAt,
    );
  }

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
