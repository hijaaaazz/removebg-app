import 'package:removeit_app/features/quota/domain/entities/user_quota_entity.dart';

class UserQuotaModel extends UserQuotaEntity {
  const UserQuotaModel({
    required super.plan,
    required super.baseLimit,
    required super.adBonusGranted,
    required super.totalAllowed,
    required super.used,
    required super.remaining,
    required super.bonusAdsRemainingToday,
    super.resetsAt,
  });

  factory UserQuotaModel.fromJson(Map<String, dynamic> json) {
    DateTime? resetTime;
    if (json['resets_at'] != null) {
      resetTime = DateTime.tryParse(json['resets_at'] as String);
    }

    String planStr = 'free';
    if (json['plan'] is String) {
      planStr = json['plan'] as String;
    } else if (json['plan'] is Map) {
      final pMap = json['plan'] as Map<String, dynamic>;
      planStr = (pMap['code'] ?? pMap['name'] ?? 'free').toString();
    }

    return UserQuotaModel(
      plan: planStr,
      baseLimit: json['base_limit'] as int? ?? 1,
      adBonusGranted: json['ad_bonus_granted'] as int? ?? 0,
      totalAllowed: json['total_allowed'] as int? ?? 1,
      used: json['used'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 1,
      bonusAdsRemainingToday: json['bonus_ads_remaining_today'] as int? ?? 2,
      resetsAt: resetTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'base_limit': baseLimit,
      'ad_bonus_granted': adBonusGranted,
      'total_allowed': totalAllowed,
      'used': used,
      'remaining': remaining,
      'bonus_ads_remaining_today': bonusAdsRemainingToday,
      'resets_at': resetsAt?.toIso8601String(),
    };
  }
}
