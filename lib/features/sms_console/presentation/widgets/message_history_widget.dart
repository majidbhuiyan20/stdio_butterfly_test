import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sms_providers.dart';
import '../../domain/entities/sms_message.dart';

class MessageHistoryWidget extends ConsumerWidget {
  const MessageHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(messageHistoryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Message History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: historyAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('No messages sent yet.')),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _buildStatusIcon(message.status),
                          title: Text(message.recipient),
                          subtitle: Text(
                            '${DateFormat('MMM d, HH:mm').format(message.sentAt)} • ${message.segmentCount} segments',
                          ),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${message.currency} ${message.cost.toStringAsFixed(4)}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  message.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getStatusColor(message.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(SmsStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case SmsStatus.delivered:
        icon = Icons.check_circle;
        color = Colors.green;
      case SmsStatus.failed:
        icon = Icons.error;
        color = Colors.red;
      case SmsStatus.sent:
        icon = Icons.send;
        color = Colors.blue;
      case SmsStatus.accepted:
        icon = Icons.access_time;
        color = Colors.orange;
    }
    return Icon(icon, color: color, size: 20);
  }

  Color _getStatusColor(SmsStatus status) {
    switch (status) {
      case SmsStatus.delivered:
        return Colors.green;
      case SmsStatus.failed:
        return Colors.red;
      case SmsStatus.sent:
        return Colors.blue;
      case SmsStatus.accepted:
        return Colors.orange;
    }
  }
}
