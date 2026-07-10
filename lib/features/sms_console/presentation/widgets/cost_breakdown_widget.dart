import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sms_providers.dart';

class CostBreakdownWidget extends ConsumerWidget {
  const CostBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(costBreakdownProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cost Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            breakdownAsync.when(
              data: (breakdown) => Column(
                children: [
                  ...breakdown.rows.map((row) => ListTile(
                        title: Text(row.provider),
                        subtitle: Text('${row.messageCount} messages'),
                        trailing: Text(
                          '${breakdown.currency} ${row.totalCost.toStringAsFixed(4)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                  const Divider(),
                  ListTile(
                    title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '${breakdown.currency} ${breakdown.totalCost.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
