import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:removeit_app/app.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.bootstrap(Flavor.prod);
  await initInjection();

  if (EnvConfig.instance.enableAdmob) {
    unawaited(_initMobileAds());
  }

  runApp(const RemoveItApp());
}

Future<void> _initMobileAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('[AdMob] Failed to initialize: $e');
  }
}
