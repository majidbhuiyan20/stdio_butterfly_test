import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/sms_providers.dart';

class SmsSendForm extends ConsumerStatefulWidget {
  const SmsSendForm({super.key});

  @override
  ConsumerState<SmsSendForm> createState() => _SmsSendFormState();
}

class _SmsSendFormState extends ConsumerState<SmsSendForm> {
  final _phoneController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smsNotifierProvider);

    ref.listen(smsNotifierProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        AppSnackBar.show(
          context,
          message: next.error!,
          type: AppSnackBarType.error,
        );
      }
      if (next.lastSentMessage != null &&
          previous?.lastSentMessage != next.lastSentMessage) {
        AppSnackBar.show(
          context,
          message: 'Message sent! ID: ${next.lastSentMessage!.id}',
          type: AppSnackBarType.success,
        );
        _bodyController.clear();
      }
    });

    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Send SMS', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Recipient (E.164)',
                  hintText: '+4915112345678',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  // Simple E.164 validation
                  if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
                    return 'Invalid E.164 format (e.g. +4915112345678)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Message Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(smsNotifierProvider.notifier).sendSms(
                                _phoneController.text,
                                _bodyController.text,
                              );
                        }
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
