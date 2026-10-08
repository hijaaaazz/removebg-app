import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:removeit_app/app.dart';
import 'package:removeit_app/core/config/env_config.dart';
import 'package:removeit_app/injection_container.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await GetIt.instance.reset();

    EnvConfig.initialize(
      flavor: Flavor.dev,
      apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
      appTitle: 'RemoveIt (Dev)',
      enableLogging: false,
      admobBannerId: 'test_banner',
      admobRewardedId: 'test_rewarded',
      admobInterstitialId: 'test_interstitial',
    );

    await initInjection();
  });

  testWidgets('App smoke test renders home studio screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RemoveItApp());
    await tester.pumpAndSettle();

    expect(find.text('RemoveIt Studio'), findsOneWidget);
    expect(find.text('Remove Background Instantly'), findsOneWidget);
  });
}
