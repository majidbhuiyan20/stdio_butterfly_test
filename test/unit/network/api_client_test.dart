import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:studio_butterfly_test/core/config/env_config.dart';
import 'package:studio_butterfly_test/core/network/api_client.dart';
import 'package:studio_butterfly_test/core/error/failures.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiClient apiClient;
  late MockHttpClient mockHttpClient;
  late EnvConfig config;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    config = EnvConfig(
      apiBaseUrl: 'https://api.test.com',
      apiKey: 'test_key',
      tenantId: 'test_tenant',
    );
    apiClient = ApiClient(mockHttpClient, config);
  });

  group('ApiClient Tests', () {
    test('should add mandatory headers to GET requests', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'data': 'ok'}), 200));

      await apiClient.get('/test');

      verify(() => mockHttpClient.get(
            Uri.parse('https://api.test.com/test'),
            headers: {
              'Authorization': 'Bearer test_key',
              'X-Tenant-Id': 'test_tenant',
              'Content-Type': 'application/json',
            },
          )).called(1);
    });

    test('should add mandatory headers to POST requests', () async {
      when(() => mockHttpClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode({'data': 'ok'}), 200));

      await apiClient.post('/test', {'key': 'value'});

      verify(() => mockHttpClient.post(
            Uri.parse('https://api.test.com/test'),
            headers: {
              'Authorization': 'Bearer test_key',
              'X-Tenant-Id': 'test_tenant',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'key': 'value'}),
          )).called(1);
    });

    test('should throw ServerFailure on 429 Rate Limit', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Too Many Requests', 429));

      expect(
        () => apiClient.get('/test'),
        throwsA(isA<ServerFailure>().having((e) => e.message, 'message', contains('Rate limit'))),
      );
    });
  });
}
