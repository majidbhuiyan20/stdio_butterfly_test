import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_butterfly_test/core/network/api_client.dart';
import 'package:studio_butterfly_test/core/network/api_endpoints.dart';
import 'package:studio_butterfly_test/features/sms_console/data/repositories/sms_repository_impl.dart';
import 'package:studio_butterfly_test/features/sms_console/domain/entities/sms_message.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late SmsRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = SmsRepositoryImpl(mockApiClient);
  });

  group('SmsRepositoryImpl', () {
    test(
      'sendSms should use values from server response, not local logic',
      () async {
        // Setup: Server returns different values than what a "local" logic might guess
        final response = {
          "messageId": "SM_SERVER_ID",
          "status": "SENT",
          "segmentCount": 3, // Server says 3 segments
          "cost": "0.2250", // Server says 0.2250
          "currency": "EUR",
        };

        when(
          () => mockApiClient.post(any(), any()),
        ).thenAnswer((_) async => response);

        final result = await repository.sendSms(
          to: '+4915112345678',
          body: 'Short body', // Local logic might guess 1 segment
        );

        // Verify ApiClient was called with correct endpoint
        verify(() => mockApiClient.post(ApiEndpoints.sendSms, any())).called(1);

        // Verify result matches server response, not local guesses
        expect(result.id, "SM_SERVER_ID");
        expect(result.segmentCount, 3);
        expect(result.cost, Decimal.parse('0.2250'));
        expect(result.status, SmsStatus.sent);
      },
    );

    test('getMessages should map items correctly', () async {
      final response = {
        "items": [
          {
            "messageId": "SM1",
            "recipient": "+4915*****78",
            "status": "DELIVERED",
            "segmentCount": 1,
            "cost": "0.0750",
            "sentAt": "2026-07-09T08:14:22Z",
          },
        ],
        "nextCursor": null,
      };

      when(
        () => mockApiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => response);

      final result = await repository.getMessages();

      expect(result.length, 1);
      expect(result.first.id, "SM1");
      expect(result.first.status, SmsStatus.delivered);
    });
  });
}
