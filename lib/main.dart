import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:removeit_app/app.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/features/monetization/data/datasources/revenuecat_data_source.dart';
import 'package:removeit_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.bootstrap(Flavor.dev);
  await initInjection();

  if (EnvConfig.instance.enableAdmob) {
    unawaited(_initMobileAds());
  }

  unawaited(_initRevenueCat());

  runApp(const RemoveItApp());
}

Future<void> _initMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('[AdMob] Failed to initialize: $e');
  }
}

Future<void> _initRevenueCat() async {
  try {
    await sl<RevenueCatDataSource>().initialize();
  } catch (e) {
    debugPrint('[RevenueCat] Failed to initialize: $e');
  }
}
