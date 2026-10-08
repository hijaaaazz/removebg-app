import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/core/constants/api_endpoints.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/features/monetization/data/models/ad_config_model.dart';
import 'package:removeit_app/features/monetization/domain/entities/ad_config_entity.dart';

abstract class AdMobDataSource {
  Future<AdConfigEntity> fetchAdConfig();
  Future<void> showRewardedBonusAd({
    required String userId,
    required VoidCallback onRewardGranted,
    required void Function(String error) onFailure,
  });
}

class AdMobDataSourceImpl implements AdMobDataSource {
  final ApiClient apiClient;
  RewardedAd? _rewardedAd;

  AdMobDataSourceImpl(this.apiClient);

  @override
  Future<AdConfigEntity> fetchAdConfig() async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.adsConfig,
        queryParameters: {'platform': platform},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return AdConfigModel.fromJson(data);
    } catch (_) {
      // Fallback to EnvConfig test IDs
      return AdConfigEntity(
        bannerEnabled: true,
        rewardedEnabled: true,
        interstitialEnabled: false,
        placements: {
          'home_banner': AdPlacementEntity(
            unitId: EnvConfig.instance.admobBannerId,
            network: 'admob',
          ),
          'reward_bonus': AdPlacementEntity(
            unitId: EnvConfig.instance.admobRewardedId,
            network: 'admob',
          ),
        },
      );
    }
  }

  @override
  Future<void> showRewardedBonusAd({
    required String userId,
    required VoidCallback onRewardGranted,
    required void Function(String error) onFailure,
  }) async {
    try {
      // 1. Initiate session with Django backend to receive cryptographic nonce
      final sessionResponse = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.adsRewardedStart,
      );
      final data = sessionResponse.data!['data'] as Map<String, dynamic>;
      final nonce = data['nonce'] as String;

      // 2. Load AdMob Rewarded Ad
      final adUnitId = EnvConfig.instance.admobRewardedId;

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;

            // Attach Server-Side Verification options with customData = nonce
            _rewardedAd!.setServerSideOptions(
              ServerSideVerificationOptions(
                userId: userId,
                customData: nonce,
              ),
            );

            // 3. Show Ad
            _rewardedAd!.show(
              onUserEarnedReward: (AdWithoutView adView, RewardItem reward) {
                onRewardGranted();
              },
            );
          },
          onAdFailedToLoad: (error) {
            onFailure(error.message);
          },
        ),
      );
    } catch (e) {
      onFailure(e.toString());
    }
  }
}
