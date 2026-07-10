import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../widgets/sms_send_form.dart';
import '../widgets/cost_breakdown_widget.dart';
import '../widgets/message_history_widget.dart';

class SmsConsolePage extends StatelessWidget {
  const SmsConsolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Butterfly SMS'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {}, // Tenant switching placeholder
          ),
        ],
      ),
      body: const ResponsiveLayout(
        mobile: _MobileLayout(),
        desktop: _DesktopLayout(),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SmsSendForm(),
          SizedBox(height: 16),
          CostBreakdownWidget(),
          SizedBox(height: 16),
          MessageHistoryWidget(),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SmsSendForm(),
                  SizedBox(height: 24),
                  MessageHistoryWidget(),
                ],
              ),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: CostBreakdownWidget(),
          ),
        ],
      ),
    );
  }
}
