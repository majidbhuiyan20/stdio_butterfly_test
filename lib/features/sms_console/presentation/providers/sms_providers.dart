import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/sms_repository_impl.dart';
import '../../domain/repositories/sms_repository.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/entities/cost_breakdown.dart';

final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SmsRepositoryImpl(apiClient);
});

final costBreakdownProvider = FutureProvider<CostBreakdown>((ref) async {
  final repository = ref.watch(smsRepositoryProvider);
  // Using a fixed range for now, as per the simple UI requirement
  return repository.getCostBreakdown(
    from: DateTime.now().subtract(const Duration(days: 30)),
    to: DateTime.now(),
  );
});

final messageHistoryProvider = FutureProvider<List<SmsMessage>>((ref) async {
  final repository = ref.watch(smsRepositoryProvider);
  return repository.getMessages();
});

class SmsSendState {
  final bool isLoading;
  final String? error;
  final SmsMessage? lastSentMessage;

  SmsSendState({this.isLoading = false, this.error, this.lastSentMessage});

  SmsSendState copyWith({bool? isLoading, String? error, SmsMessage? lastSentMessage}) {
    return SmsSendState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSentMessage: lastSentMessage ?? this.lastSentMessage,
    );
  }
}

class SmsNotifier extends StateNotifier<SmsSendState> {
  final SmsRepository _repository;
  final Ref _ref;

  SmsNotifier(this._repository, this._ref) : super(SmsSendState());

  Future<void> sendSms(String to, String body) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final message = await _repository.sendSms(to: to, body: body);
      state = state.copyWith(isLoading: false, lastSentMessage: message);
      // Refresh breakdown and history
      _ref.invalidate(costBreakdownProvider);
      _ref.invalidate(messageHistoryProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final smsNotifierProvider = StateNotifierProvider<SmsNotifier, SmsSendState>((ref) {
  final repository = ref.watch(smsRepositoryProvider);
  return SmsNotifier(repository, ref);
});
