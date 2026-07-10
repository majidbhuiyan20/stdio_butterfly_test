import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_butterfly_test/core/config/env_config.dart';
import 'package:studio_butterfly_test/core/providers/core_providers.dart';
import 'package:studio_butterfly_test/main.dart';

void main() {
  testWidgets('SMS console page smoke test', (WidgetTester tester) async {
    final testConfig = EnvConfig(
      apiBaseUrl: 'https://api.test.com',
      apiKey: 'test_key',
      tenantId: 'test_tenant',
    );

    // Build our app and trigger a frame with overridden environment config
    // so the app does not need a real .env file in the test environment.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [envConfigProvider.overrideWithValue(testConfig)],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    // Verify the app title appears in the AppBar.
    expect(find.text('Studio Butterfly SMS'), findsOneWidget);
  });
}
