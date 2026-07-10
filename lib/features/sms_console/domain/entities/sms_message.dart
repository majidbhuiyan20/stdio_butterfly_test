import 'package:decimal/decimal.dart';

enum SmsStatus { accepted, sent, delivered, failed }

class SmsMessage {
  final String id;
  final String recipient;
  final SmsStatus status;
  final int segmentCount;
  final Decimal cost;
  final String currency;
  final DateTime sentAt;

  SmsMessage({
    required this.id,
    required this.recipient,
    required this.status,
    required this.segmentCount,
    required this.cost,
    required this.currency,
    required this.sentAt,
  });
}
