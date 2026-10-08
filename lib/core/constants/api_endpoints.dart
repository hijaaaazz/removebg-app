import 'package:removeit_app/core/config/env_config.dart';

class ApiEndpoints {
  static String get baseUrl => EnvConfig.instance.apiBaseUrl;

  // Authentication
  static const String authGoogle = '/auth/google/';
  static const String authRefresh = '/auth/refresh/';
  static const String authMe = '/me/';

  // Jobs & Processing
  static const String jobs = '/jobs/';
  static String jobDetail(String id) => '/jobs/$id/';
  static String jobClaim(String id) => '/jobs/$id/claim/';

  // Quota & Limits
  static const String quota = '/quota/';

  // Ads & Mediation
  static const String adsConfig = '/ads/config/';
  static const String adsRewardedStart = '/ads/rewarded/start/';
  static const String adsRewardedClaim = '/ads/rewarded/claim/';

  // History
  static const String history = '/history/';
  static String historyDelete(String id) => '/history/$id/';
  static const String historyBulkDelete = '/history/delete/';

  // System Flags
  static const String flags = '/flags/';
}
