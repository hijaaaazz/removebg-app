import 'package:flutter/material.dart';
import 'package:removeit_app/app.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(
    flavor: Flavor.dev,
    apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
    appTitle: 'RemoveIt (Dev)',
    enableLogging: true,
    admobBannerId: 'ca-app-pub-3940256099942544/6300978111',
    admobRewardedId: 'ca-app-pub-3940256099942544/5224354917',
    admobInterstitialId: 'ca-app-pub-3940256099942544/1033173712',
  );

  await initInjection();

  runApp(const RemoveItApp());
}
