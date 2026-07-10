import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../network/api_client.dart';

final httpClientProvider = Provider((ref) => http.Client());

final envConfigProvider = Provider((ref) => EnvConfig.fromDotEnv());

final apiClientProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  final config = ref.watch(envConfigProvider);
  return ApiClient(client, config);
});
