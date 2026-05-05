import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiService {
  Uri _uri(String endpoint) => Uri.parse('${ApiConfig.baseUrl}$endpoint');

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.get(_uri(endpoint), headers: _headers(token: token));
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? multipartFields,
    List<int>? multipartFileBytes,
    String? multipartFileField,
    String? multipartFileName,
    MediaType? multipartFileContentType,
  }) async {
    final uri = _uri(endpoint);
    print('═══════════════════════════════════════════════════════════');
    print('📤 POSTING TO: $uri');
    print('Headers: ${_headers(token: token)}');
    print('Body: ${jsonEncode(body ?? <String, dynamic>{})}');
    print('═══════════════════════════════════════════════════════════');
    
    if (multipartFileBytes != null) {
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(_headers(token: token, includeContentType: false));
      if (multipartFields != null) {
        request.fields.addAll(multipartFields);
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          multipartFileField ?? 'file',
          multipartFileBytes,
          filename: multipartFileName ?? 'upload.bin',
          contentType: multipartFileContentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return handleResponse(response);
    }

    final response = await http.post(
      _uri(endpoint),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? multipartFields,
    List<int>? multipartFileBytes,
    String? multipartFileField,
    String? multipartFileName,
    MediaType? multipartFileContentType,
  }) async {
    final uri = _uri(endpoint);
    print('═══════════════════════════════════════════════════════════');
    print('📤 PATCHING TO: $uri');
    print('Headers: ${_headers(token: token)}');
    print('Body: ${jsonEncode(body ?? <String, dynamic>{})}');
    print('═══════════════════════════════════════════════════════════');
    if (multipartFields != null || multipartFileBytes != null) {
      final request = http.MultipartRequest('PATCH', _uri(endpoint));
      request.headers.addAll(_headers(token: token, includeContentType: false));
      if (multipartFields != null) {
        request.fields.addAll(multipartFields);
      }

      if (multipartFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            multipartFileField ?? 'file',
            multipartFileBytes,
            filename: multipartFileName ?? 'upload.bin',
            contentType: multipartFileContentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return handleResponse(response);
    }

    final response = await http.patch(
      _uri(endpoint),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = _uri(endpoint);
    print('═══════════════════════════════════════════════════════════');
    print('📤 PUTTING TO: $uri');
    print('Headers: ${_headers(token: token)}');
    print('Body: ${jsonEncode(body ?? <String, dynamic>{})}');
    print('═══════════════════════════════════════════════════════════');

    final response = await http.put(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final response = await http.delete(_uri(endpoint), headers: _headers(token: token));
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required File file,
    required String fileFieldName,
    String? token,
  }) async {
    final uri = _uri(endpoint);
    print('═══════════════════════════════════════════════════════════');
    print('📤 POST MULTIPART TO: $uri');
    print('Fields: $fields');
    print('File: ${file.path}');
    print('═══════════════════════════════════════════════════════════');

    final request = http.MultipartRequest('POST', uri);
    
    // Add headers
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add fields
    request.fields.addAll(fields);
    
    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      fileFieldName,
      file.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return handleResponse(response);
  }

  Map<String, String> _headers({String? token, bool includeContentType = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    print('═══════════════════════════════════════════════════════════');
    print('🔍 API RESPONSE DEBUG INFO');
    print('═══════════════════════════════════════════════════════════');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('═══════════════════════════════════════════════════════════');

    Map<String, dynamic> data = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is List) {
          data = <String, dynamic>{'data': decoded};
        } else if (decoded is String) {
          data = <String, dynamic>{'msg': decoded};
        } else {
          data = <String, dynamic>{'data': decoded};
        }
      } catch (_) {
        print('❌ Failed to parse JSON response');
        throw ApiException('Invalid response format from server.', statusCode: response.statusCode);
        final preview = response.body.length > 180
            ? '${response.body.substring(0, 180)}...'
            : response.body;
        throw ApiException(
          'Server returned a non-JSON response (${response.statusCode}): $preview',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Success response');
      return data;
    }

    final errorMessage = (data['msg'] ?? data['error'] ?? 'Request failed').toString();
    print('❌ Error: $errorMessage (Status: ${response.statusCode})');
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }
}