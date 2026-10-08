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
  void preloadRewardedAd();
  Future<void> showRewardedBonusAd({
    required String userId,
    required VoidCallback onRewardGranted,
    VoidCallback? onAdCancelled,
    required void Function(String error) onFailure,
  });
}

class AdMobDataSourceImpl implements AdMobDataSource {
  final ApiClient apiClient;
  RewardedAd? _preloadedRewardedAd;
  bool _isPreloading = false;

  AdMobDataSourceImpl(this.apiClient);

  @override
  Future<AdConfigEntity> fetchAdConfig() async {
    if (!EnvConfig.instance.enableAdmob) {
      return const AdConfigEntity(
        bannerEnabled: false,
        rewardedEnabled: false,
        interstitialEnabled: false,
        placements: {},
      );
    }
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.adsConfig,
        queryParameters: {'platform': platform},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return AdConfigModel.fromJson(data);
    } catch (_) {
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

  /// Preloads a rewarded ad in the background to achieve zero-delay (0ms) launch.
  @override
  void preloadRewardedAd() {
    if (!EnvConfig.instance.enableAdmob) return;
    if (_preloadedRewardedAd != null || _isPreloading) return;

    _isPreloading = true;
    final adUnitId = EnvConfig.instance.admobRewardedId;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isPreloading = false;
          _preloadedRewardedAd = ad;
          debugPrint('[AdMob] Preloaded rewarded ad ready for 0ms launch.');
        },
        onAdFailedToLoad: (error) {
          _isPreloading = false;
          _preloadedRewardedAd = null;
          debugPrint('[AdMob] Preload ad failed: ${error.message}');
        },
      ),
    );
  }

  @override
  Future<void> showRewardedBonusAd({
    required String userId,
    required VoidCallback onRewardGranted,
    VoidCallback? onAdCancelled,
    required void Function(String error) onFailure,
  }) async {
    String? nonce;
    try {
      final sessionResponse = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.adsRewardedStart,
      );
      final data = sessionResponse.data!['data'] as Map<String, dynamic>;
      nonce = data['nonce'] as String?;
    } catch (e) {
      debugPrint('[AdMob] Could not obtain ad session nonce: $e');
    }

    Future<void> claimBonusOnBackend() async {
      if (nonce != null && nonce.isNotEmpty) {
        try {
          await apiClient.post<Map<String, dynamic>>(
            ApiEndpoints.adsRewardedClaim,
            data: {'nonce': nonce},
          );
        } catch (e) {
          debugPrint('[AdMob] Error claiming ad reward on backend: $e');
        }
      }
    }

    if (!EnvConfig.instance.enableAdmob) {
      debugPrint('[AdMob] Ads disabled in current env. Claiming mock reward for testing.');
      await claimBonusOnBackend();
      onRewardGranted();
      return;
    }

    // Use preloaded ad for 0ms instantaneous display, or load on-demand
    final adToShow = _preloadedRewardedAd;
    _preloadedRewardedAd = null;

    if (adToShow != null) {
      _showLoadedAd(
        adToShow,
        userId: userId,
        nonce: nonce,
        claimBonusOnBackend: claimBonusOnBackend,
        onRewardGranted: onRewardGranted,
        onAdCancelled: onAdCancelled,
        onFailure: onFailure,
      );
      return;
    }

    // Fallback: load on-demand if preload was not ready
    try {
      final adUnitId = EnvConfig.instance.admobRewardedId;

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _showLoadedAd(
              ad,
              userId: userId,
              nonce: nonce,
              claimBonusOnBackend: claimBonusOnBackend,
              onRewardGranted: onRewardGranted,
              onAdCancelled: onAdCancelled,
              onFailure: onFailure,
            );
          },
          onAdFailedToLoad: (error) async {
            debugPrint('[AdMob] Failed to load ad: ${error.message}');
            await claimBonusOnBackend();
            onFailure(error.message);
            preloadRewardedAd();
          },
        ),
      );
    } catch (e) {
      await claimBonusOnBackend();
      onFailure(e.toString());
      preloadRewardedAd();
    }
  }

  void _showLoadedAd(
    RewardedAd ad, {
    required String userId,
    required String? nonce,
    required Future<void> Function() claimBonusOnBackend,
    required VoidCallback onRewardGranted,
    VoidCallback? onAdCancelled,
    required void Function(String error) onFailure,
  }) {
    bool rewardEarned = false;

    if (nonce != null && nonce.isNotEmpty) {
      ad.setServerSideOptions(
        ServerSideVerificationOptions(
          userId: userId,
          customData: nonce,
        ),
      );
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdMob] Ad showing full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        // Immediately preload the next ad in the background
        preloadRewardedAd();

        if (rewardEarned) {
          debugPrint('[AdMob] Ad dismissed with reward earned. Proceeding with user action.');
          onRewardGranted();
        } else {
          debugPrint('[AdMob] User cancelled/dismissed ad before reward. Server call aborted.');
          onAdCancelled?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadRewardedAd();
        debugPrint('[AdMob] Failed to show ad: ${error.message}');
        onFailure(error.message);
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView adView, RewardItem reward) async {
        rewardEarned = true;
        await claimBonusOnBackend();
      },
    );
  }
}
