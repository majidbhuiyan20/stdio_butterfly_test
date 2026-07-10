import 'package:decimal/decimal.dart';

import '../../domain/entities/cost_breakdown.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/repositories/sms_repository.dart';
import '../models/cost_breakdown_model.dart';
import '../models/sms_message_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class SmsRepositoryImpl implements SmsRepository {
  final ApiClient _apiClient;

  SmsRepositoryImpl(this._apiClient);

  @override
  Future<SmsMessage> sendSms({
    required String to,
    required String body,
    String? referenceId,
  }) async {
    final response = await _apiClient.post(ApiEndpoints.sendSms, {
      'to': to,
      'body': body,
      if (referenceId != null) 'referenceId': referenceId,
    });
    
    return SmsMessageModel(
      id: response['messageId'] as String,
      recipient: to,
      status: _parseStatus(response['status'] as String),
      segmentCount: response['segmentCount'] as int,
      cost: Decimal.parse(response['cost'] as String),
      currency: response['currency'] as String,
      sentAt: DateTime.now(),
    );
  }

  @override
  Future<CostBreakdown> getCostBreakdown({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.costBreakdown,
      query: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );
    return CostBreakdownModel.fromJson(response);
  }

  @override
  Future<List<SmsMessage>> getMessages({
    String? cursor,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.messagesHistory,
      query: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit.toString(),
      },
    );
    
    final items = response['items'] as List<dynamic>;
    return items.map((json) => SmsMessageModel.fromJson(json)).toList();
  }

  SmsStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return SmsStatus.accepted;
      case 'SENT': return SmsStatus.sent;
      case 'DELIVERED': return SmsStatus.delivered;
      case 'FAILED': return SmsStatus.failed;
      default: return SmsStatus.accepted;
    }
  }
}
