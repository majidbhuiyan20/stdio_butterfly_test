import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../error/failures.dart';

class ApiClient {
  final http.Client _client;
  final EnvConfig _config;

  ApiClient(this._client, this._config);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${_config.apiBaseUrl}$path',
    ).replace(queryParameters: query);

    try {
      final response = await _client.get(uri, headers: _headers);
      return _handleResponse(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${_config.apiBaseUrl}$path');

    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_config.apiKey}',
    'X-Tenant-Id': _config.tenantId,
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 429) {
      throw ServerFailure('Rate limit exceeded. Please try again later.');
    } else {
      final data = jsonDecode(response.body);
      throw ServerFailure(data['message'] ?? 'Server error occurred');
    }
  }
}
