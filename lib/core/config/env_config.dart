import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class EnvConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appTitle;
  final bool enableLogging;
  final bool enableAdmob;
  final String admobBannerId;
  final String admobRewardedId;
  final String admobInterstitialId;
  final String revenueCatAndroidKey;
  final String revenueCatIosKey;
  final String googleServerClientId;
  final String googleIosClientId;

  static late EnvConfig instance;

  EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
    required this.enableLogging,
    required this.enableAdmob,
    required this.admobBannerId,
    required this.admobRewardedId,
    required this.admobInterstitialId,
    required this.revenueCatAndroidKey,
    required this.revenueCatIosKey,
    required this.googleServerClientId,
    required this.googleIosClientId,
  });

  /// Production-grade asynchronous bootstrap loading from .env files and compile-time defines.
  static Future<void> bootstrap(Flavor flavor) async {
    final envFileName = 'assets/env/.env.${flavor.name}';
    try {
      await dotenv.load(fileName: envFileName);
    } catch (_) {
      try {
        await dotenv.load(fileName: 'assets/env/.env.example');
      } catch (_) {
        // Fallback to internal defaults if no .env asset is bundled
      }
    }

    String getEnv(String key, {String defaultValue = ''}) {
      // 1. Compile-time --dart-define has highest priority
      if (String.fromEnvironment(key).isNotEmpty) {
        return String.fromEnvironment(key);
      }
      // 2. Value from .env file
      final dotenvVal = dotenv.maybeGet(key);
      if (dotenvVal != null && dotenvVal.isNotEmpty) {
        return dotenvVal;
      }
      // 3. Safe fallback default
      return defaultValue;
    }

    bool getEnvBool(String key, {bool defaultValue = false}) {
      if (bool.hasEnvironment(key)) {
        return bool.fromEnvironment(key);
      }
      final dotenvVal = dotenv.maybeGet(key);
      if (dotenvVal != null && dotenvVal.isNotEmpty) {
        return dotenvVal.toLowerCase() == 'true' || dotenvVal == '1';
      }
      return defaultValue;
    }

    final defaultApiUrl = switch (flavor) {
      Flavor.prod => 'https://api.removebg.app/api/v1',
      Flavor.staging => 'https://staging-api.removebg.app/api/v1',
      Flavor.dev => 'http://127.0.0.1:8000/api/v1',
    };

    final defaultTitle = switch (flavor) {
      Flavor.prod => 'RemoveIt',
      Flavor.staging => 'RemoveIt (Staging)',
      Flavor.dev => 'RemoveIt (Dev)',
    };

    instance = EnvConfig._(
      flavor: flavor,
      apiBaseUrl: getEnv('API_BASE_URL', defaultValue: defaultApiUrl),
      appTitle: getEnv('APP_TITLE', defaultValue: defaultTitle),
      enableLogging: getEnvBool('ENABLE_LOGGING', defaultValue: flavor != Flavor.prod),
      enableAdmob: getEnvBool('ENABLE_ADMOB', defaultValue: flavor == Flavor.prod),
      admobBannerId: getEnv('ADMOB_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/6300978111'),
      admobRewardedId: getEnv('ADMOB_REWARDED_ID', defaultValue: 'ca-app-pub-3940256099942544/5224354917'),
      admobInterstitialId: getEnv('ADMOB_INTERSTITIAL_ID', defaultValue: 'ca-app-pub-3940256099942544/1033173712'),
      revenueCatAndroidKey: getEnv('REVENUECAT_ANDROID_KEY', defaultValue: 'goog_sample_key_android'),
      revenueCatIosKey: getEnv('REVENUECAT_IOS_KEY', defaultValue: 'appl_sample_key_ios'),
      googleServerClientId: getEnv('GOOGLE_SERVER_CLIENT_ID', defaultValue: ''),
      googleIosClientId: getEnv('GOOGLE_IOS_CLIENT_ID', defaultValue: '429257074599-if1rckn5417kcj2p1f3lva4pujeh32v5.apps.googleusercontent.com'),
    );
  }

  /// Synchronous initialization method for unit and widget tests.
  static void initialize({
    required Flavor flavor,
    required String apiBaseUrl,
    required String appTitle,
    required bool enableLogging,
    bool enableAdmob = false,
    required String admobBannerId,
    required String admobRewardedId,
    required String admobInterstitialId,
    String revenueCatAndroidKey = 'goog_sample_key_android',
    String revenueCatIosKey = 'appl_sample_key_ios',
    String googleServerClientId = '',
    String googleIosClientId = '429257074599-if1rckn5417kcj2p1f3lva4pujeh32v5.apps.googleusercontent.com',
  }) {
    instance = EnvConfig._(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      appTitle: appTitle,
      enableLogging: enableLogging,
      enableAdmob: enableAdmob,
      admobBannerId: admobBannerId,
      admobRewardedId: admobRewardedId,
      admobInterstitialId: admobInterstitialId,
      revenueCatAndroidKey: revenueCatAndroidKey,
      revenueCatIosKey: revenueCatIosKey,
      googleServerClientId: googleServerClientId,
      googleIosClientId: googleIosClientId,
    );
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
