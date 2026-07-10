import 'dart:async';
import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../domain/entities/cost_breakdown.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/repositories/sms_repository.dart';

class MockSmsRepository implements SmsRepository {
  final List<SmsMessage> _messages = [];
  final _random = Random();

  MockSmsRepository() {
    // Add some initial mock data
    _messages.addAll([
      SmsMessage(
        id: 'SM1',
        recipient: '+4915*****78',
        status: SmsStatus.delivered,
        segmentCount: 1,
        cost: Decimal.parse('0.0750'),
        currency: 'EUR',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SmsMessage(
        id: 'SM2',
        recipient: '+4477*****12',
        status: SmsStatus.failed,
        segmentCount: 2,
        cost: Decimal.parse('0.1500'),
        currency: 'EUR',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<SmsMessage> sendSms({
    required String to,
    required String body,
    String? referenceId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate potential 429 Rate Limit (1 in 10 chance)
    if (_random.nextInt(10) == 0) {
      throw Exception('Rate limit exceeded. Retry-After: 30s');
    }

    final message = SmsMessage(
      id: 'SM${_random.nextInt(100000)}',
      recipient: to.replaceRange(5, to.length - 2, '*****'),
      status: SmsStatus.accepted,
      segmentCount: (body.length / 160).ceil(),
      cost: Decimal.parse('0.0750') * Decimal.fromInt((body.length / 160).ceil()),
      currency: 'EUR',
      sentAt: DateTime.now(),
    );

    _messages.insert(0, message);
    return message;
  }

  @override
  Future<CostBreakdown> getCostBreakdown({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final totalMessages = _messages.length;
    final twilioCount = (totalMessages * 0.6).round();
    final awsCount = totalMessages - twilioCount;

    final twilioCost = Decimal.parse('0.0750') * Decimal.fromInt(twilioCount);
    final awsCost = Decimal.parse('0.0450') * Decimal.fromInt(awsCount);

    return CostBreakdown(
      currency: 'EUR',
      totalCost: twilioCost + awsCost,
      rows: [
        CostRow(
          provider: 'TWILIO',
          totalCost: twilioCost,
          messageCount: twilioCount,
        ),
        CostRow(
          provider: 'AWS_SNS',
          totalCost: awsCost,
          messageCount: awsCount,
        ),
      ],
    );
  }

  @override
  Future<List<SmsMessage>> getMessages({
    String? cursor,
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _messages;
  }
}
