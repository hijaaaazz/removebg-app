import 'package:equatable/equatable.dart';

class AdPlacementEntity extends Equatable {
  final String unitId;
  final String network;

  const AdPlacementEntity({required this.unitId, required this.network});

  @override
  List<Object?> get props => [unitId, network];
}

class AdConfigEntity extends Equatable {
  final bool bannerEnabled;
  final bool rewardedEnabled;
  final bool interstitialEnabled;
  final Map<String, AdPlacementEntity> placements;

  const AdConfigEntity({
    required this.bannerEnabled,
    required this.rewardedEnabled,
    required this.interstitialEnabled,
    required this.placements,
  });

  String? getPlacementUnitId(String key) => placements[key]?.unitId;

  @override
  List<Object?> get props => [
        bannerEnabled,
        rewardedEnabled,
        interstitialEnabled,
        placements,
      ];
}
