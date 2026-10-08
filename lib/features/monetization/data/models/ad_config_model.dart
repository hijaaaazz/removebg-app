import 'package:removeit_app/features/monetization/domain/entities/ad_config_entity.dart';

class AdConfigModel extends AdConfigEntity {
  const AdConfigModel({
    required super.bannerEnabled,
    required super.rewardedEnabled,
    required super.interstitialEnabled,
    required super.placements,
  });

  factory AdConfigModel.fromJson(Map<String, dynamic> json) {
    final placementsMap = <String, AdPlacementEntity>{};

    if (json['placements'] is Map<String, dynamic>) {
      final rawPlacements = json['placements'] as Map<String, dynamic>;
      rawPlacements.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          placementsMap[key] = AdPlacementEntity(
            unitId: val['unit_id'] as String? ?? '',
            network: val['network'] as String? ?? 'admob',
          );
        }
      });
    }

    return AdConfigModel(
      bannerEnabled: json['banner_enabled'] as bool? ?? true,
      rewardedEnabled: json['rewarded_enabled'] as bool? ?? true,
      interstitialEnabled: json['interstitial_enabled'] as bool? ?? false,
      placements: placementsMap,
    );
  }
}
