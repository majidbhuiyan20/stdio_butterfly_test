import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  final String apiBaseUrl;
  final String apiKey;
  final String tenantId;

  EnvConfig({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.tenantId,
  });

  /// Loads configuration from the .env file.
  factory EnvConfig.fromDotEnv() {
    return EnvConfig(
      apiBaseUrl: dotenv.get(
        'API_BASE_URL',
        fallback: 'http://api.formwork.internal',
      ),
      apiKey: dotenv.get('API_KEY', fallback: ''),
      tenantId: dotenv.get('TENANT_ID', fallback: ''),
    );
  }
}
