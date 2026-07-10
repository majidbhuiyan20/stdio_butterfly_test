import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_butterfly_test/features/sms_console/presentation/pages/sms_console_page.dart';
import 'package:studio_butterfly_test/features/sms_console/presentation/providers/sms_providers.dart';
import 'package:studio_butterfly_test/features/sms_console/data/repositories/mock_sms_repository.dart';

void main() {
  testWidgets('SmsConsolePage Golden Test', (WidgetTester tester) async {
    // We use the MockSmsRepository to have stable data for the golden test
    final mockRepository = MockSmsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [smsRepositoryProvider.overrideWithValue(mockRepository)],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SmsConsolePage(),
        ),
      ),
    );

    // Let the animations and initial data loading finish
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SmsConsolePage),
      matchesGoldenFile('goldens/sms_console_page.png'),
    );
  });
}
