enum Flavor { dev, staging, prod }

class EnvConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final String admobBannerId;
  final String admobRewardedId;
  final String admobInterstitialId;
  final String revenueCatAndroidKey;
  final String revenueCatIosKey;

  static late EnvConfig instance;

  EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.admobBannerId,
    required this.admobRewardedId,
    required this.admobInterstitialId,
    required this.revenueCatAndroidKey,
    required this.revenueCatIosKey,
  });

  static void initialize({
    required Flavor flavor,
    required String apiBaseUrl,
    required String appTitle,
    required bool enableLogging,
    required String admobBannerId,
    required String admobRewardedId,
    required String admobInterstitialId,
    String revenueCatAndroidKey = 'goog_sample_key_android',
    String revenueCatIosKey = 'appl_sample_key_ios',
  }) {
    instance = EnvConfig._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      appTitle: appTitle,
      enableLogging: enableLogging,
      admobBannerId: admobBannerId,
      admobRewardedId: admobRewardedId,
      admobInterstitialId: admobInterstitialId,
      revenueCatAndroidKey: revenueCatAndroidKey,
      revenueCatIosKey: revenueCatIosKey,
    );
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
