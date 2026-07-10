import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:studio_butterfly_test/features/sms_console/data/models/sms_message_model.dart';
import 'package:studio_butterfly_test/features/sms_console/data/models/cost_breakdown_model.dart';
import 'package:studio_butterfly_test/features/sms_console/domain/entities/sms_message.dart';

void main() {
  group('Model Parsing Tests', () {
    test('SmsMessageModel should parse correctly from JSON', () {
      final json = {
        "messageId": "SM3fa85f64",
        "recipient": "+4915*****78",
        "status": "DELIVERED",
        "segmentCount": 2,
        "cost": "0.1500",
        "sentAt": "2026-07-09T08:14:22Z",
      };

      final model = SmsMessageModel.fromJson(json);

      expect(model.id, "SM3fa85f64");
      expect(model.recipient, "+4915*****78");
      expect(model.status, SmsStatus.delivered);
      expect(model.segmentCount, 2);
      expect(model.cost, Decimal.parse('0.1500'));
      expect(model.sentAt, DateTime.parse("2026-07-09T08:14:22Z"));
    });

    test('CostBreakdownModel should parse correctly from JSON', () {
      final json = {
        "currency": "EUR",
        "totalCost": "12.4500",
        "rows": [
          {"provider": "TWILIO", "totalCost": "8.2500", "messageCount": 110},
          {"provider": "AWS_SNS", "totalCost": "4.2000", "messageCount": 91},
        ],
      };

      final model = CostBreakdownModel.fromJson(json);

      expect(model.currency, "EUR");
      expect(model.totalCost, Decimal.parse('12.4500'));
      expect(model.rows.length, 2);
      expect(model.rows[0].provider, "TWILIO");
      expect(model.rows[0].totalCost, Decimal.parse('8.2500'));
      expect(model.rows[0].messageCount, 110);
    });
  });
}
