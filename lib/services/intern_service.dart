import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/intern_models.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'auth_service.dart';

class InternService {
  final ApiService _apiService;
  final AuthService _authService;

  InternService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<InternAssignmentModel> fetchAssignment() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internAssignment, token: token);
    final assignment = _extractMap(response, const ['assignment', 'data']);
    return InternAssignmentModel.fromJson(assignment);
  }

  Future<List<InternScheduleModel>> fetchSchedules() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internSchedules, token: token);
    final items = _extractList(response, const ['schedules', 'data']);
    return items.map(InternScheduleModel.fromJson).toList();
  }

  Future<List<InternTrainingModuleModel>> fetchTrainingModules() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internTrainingModules, token: token);
    final items = _extractList(response, const ['trainingModules', 'training_modules', 'data']);
    return items.map(InternTrainingModuleModel.fromJson).toList();
  }

  Future<InternWorkCardModel> fetchWorkCard() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internWorkId, token: token);
    final workCard = _extractMap(response, const ['work_card', 'data']);
    return InternWorkCardModel.fromJson(workCard);
  }

  Future<List<InternEvaluationModel>> fetchEvaluations() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internEvaluations, token: token);
    final items = _extractList(response, const ['evaluations', 'data']);
    return items.map(InternEvaluationModel.fromJson).toList();
  }

  Future<InternProfileModel> fetchProfile() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.internProfile, token: token);
    final profile = _extractMap(response, const ['profile', 'data']);
    return InternProfileModel.fromJson(profile);
  }

  Future<String> uploadWorkIdPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.internWorkIdPhoto,
      token: token,
      multipartFileBytes: fileBytes,
      multipartFileField: 'file',
      multipartFileName: fileName,
      multipartFileContentType: _contentTypeForFile(fileName),
    );

    final uploadedUrl = _textOf(response['id_photo_url'] ?? (response['data'] is Map<String, dynamic> ? response['data']['id_photo_url'] : null));
    if (uploadedUrl.isEmpty) {
      throw const ApiException('Work ID photo upload did not return a file URL.');
    }
    return uploadedUrl;
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Missing auth token. Please log in again.', statusCode: 401);
    }
    return token;
  }

  Map<String, dynamic> _extractMap(Map<String, dynamic> response, List<String> keys) {
    for (final key in keys) {
      final value = response[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    final nestedData = response['data'];
    if (nestedData is Map<String, dynamic>) {
      for (final key in keys) {
        final value = nestedData[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
      }
      return nestedData;
    }

    return response;
  }

  List<dynamic> _extractList(Map<String, dynamic> response, List<String> keys) {
    for (final key in keys) {
      final value = response[key];
      if (value is List) {
        return value;
      }
    }

    final nestedData = response['data'];
    if (nestedData is List) {
      return nestedData;
    }
    if (nestedData is Map<String, dynamic>) {
      for (final key in keys) {
        final value = nestedData[key];
        if (value is List) {
          return value;
        }
      }
      final secondLevel = nestedData['data'];
      if (secondLevel is List) {
        return secondLevel;
      }
    }

    return <dynamic>[];
  }

  String _textOf(dynamic value) => value == null ? '' : value.toString();

  MediaType _contentTypeForFile(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (lowerName.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    return MediaType('application', 'octet-stream');
  }
}