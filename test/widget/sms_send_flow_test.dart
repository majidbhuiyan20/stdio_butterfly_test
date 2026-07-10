import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_butterfly_test/features/sms_console/domain/entities/sms_message.dart';
import 'package:studio_butterfly_test/features/sms_console/domain/repositories/sms_repository.dart';
import 'package:studio_butterfly_test/features/sms_console/presentation/providers/sms_providers.dart';
import 'package:studio_butterfly_test/features/sms_console/presentation/widgets/sms_send_form.dart';

class MockSmsRepository extends Mock implements SmsRepository {}

void main() {
  late MockSmsRepository mockRepository;

  setUp(() {
    mockRepository = MockSmsRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [smsRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: Scaffold(body: SmsSendForm())),
    );
  }

  testWidgets('Send SMS success flow', (tester) async {
    final successMessage = SmsMessage(
      id: 'SM123',
      recipient: '+4915112345678',
      status: SmsStatus.accepted,
      segmentCount: 1,
      cost: Decimal.parse('0.0750'),
      currency: 'EUR',
      sentAt: DateTime.now(),
    );

    when(
      () => mockRepository.sendSms(
        to: any(named: 'to'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => successMessage);

    await tester.pumpWidget(createWidgetUnderTest());

    // Enter phone and body
    await tester.enterText(find.byType(TextFormField).first, '+4915112345678');
    await tester.enterText(find.byType(TextFormField).last, 'Hello Test');

    // Tap send
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start animation

    // Verify loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Finish request and animations

    // Verify repository was called
    verify(
      () => mockRepository.sendSms(to: '+4915112345678', body: 'Hello Test'),
    ).called(1);

    // Verify success snackbar
    expect(find.text('Success'), findsOneWidget);
    expect(find.textContaining('Message sent! ID: SM123'), findsOneWidget);

    // Verify body field is cleared
    expect(find.text('Hello Test'), findsNothing);
  });

  testWidgets('Send SMS failure flow (API Error)', (tester) async {
    when(
      () => mockRepository.sendSms(
        to: any(named: 'to'),
        body: any(named: 'body'),
      ),
    ).thenThrow(Exception('Rate limit exceeded'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).first, '+4915112345678');
    await tester.enterText(find.byType(TextFormField).last, 'Hello Failure');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error snackbar
    expect(find.text('Error'), findsOneWidget);
    expect(find.textContaining('Rate limit exceeded'), findsOneWidget);
  });

  testWidgets('Validation error for invalid E.164', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).first, '123'); // Invalid
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      find.text('Invalid E.164 format (e.g. +4915112345678)'),
      findsOneWidget,
    );
    verifyNever(
      () => mockRepository.sendSms(
        to: any(named: 'to'),
        body: any(named: 'body'),
      ),
    );
  });
}
