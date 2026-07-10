import 'package:decimal/decimal.dart';
import '../entities/sms_message.dart';
import '../entities/cost_breakdown.dart';

abstract class SmsRepository {
  Future<SmsMessage> sendSms({
    required String to,
    required String body,
    String? referenceId,
  });

  Future<CostBreakdown> getCostBreakdown({
    required DateTime from,
    required DateTime to,
  });

  Future<List<SmsMessage>> getMessages({
    String? cursor,
    int limit = 50,
  });
}
