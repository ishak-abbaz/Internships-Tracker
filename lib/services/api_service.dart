import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiService {
  Uri _uri(String endpoint) => Uri.parse('${ApiConfig.baseUrl}$endpoint');

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.get(_uri(endpoint), headers: _headers(token: token));
    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.post(
      _uri(endpoint),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.patch(
      _uri(endpoint),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.delete(_uri(endpoint), headers: _headers(token: token));
    return _decodeOrThrow(response);
  }

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    Map<String, dynamic> data = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw ApiException('Invalid response format from server.', statusCode: response.statusCode);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final errorMessage = (data['msg'] ?? data['error'] ?? 'Request failed').toString();
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }
}
