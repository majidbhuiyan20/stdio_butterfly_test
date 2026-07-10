import 'package:decimal/decimal.dart';
import '../../domain/entities/sms_message.dart';

class SmsMessageModel extends SmsMessage {
  SmsMessageModel({
    required super.id,
    required super.recipient,
    required super.status,
    required super.segmentCount,
    required super.cost,
    required super.currency,
    required super.sentAt,
  });

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) {
    return SmsMessageModel(
      id: json['messageId'] as String,
      recipient: json['recipient'] as String,
      status: _parseStatus(json['status'] as String),
      segmentCount: json['segmentCount'] as int,
      cost: Decimal.parse(json['cost'] as String),
      currency: json['currency'] as String? ?? 'EUR',
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  static SmsStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return SmsStatus.accepted;
      case 'SENT':
        return SmsStatus.sent;
      case 'DELIVERED':
        return SmsStatus.delivered;
      case 'FAILED':
        return SmsStatus.failed;
      default:
        return SmsStatus.accepted;
    }
  }
}
