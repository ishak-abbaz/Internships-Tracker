import '../config/api_config.dart';
import '../models/evaluation_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EvaluationService {
  final ApiService _apiService;
  final AuthService _authService;

  EvaluationService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<EvaluationModel> createEvaluation(EvaluationModel evaluation) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.evaluations,
      token: token,
      body: evaluation.toCreatePayload(),
    );

    final data = response['data'] ?? response;
    return EvaluationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<EvaluationModel>> getInternEvaluations(String internId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.evaluations}/intern/$internId',
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is List) {
      return data
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<EvaluationModel>> getMentorEvaluations(String mentorId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.evaluations}/mentor/$mentorId',
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is List) {
      return data
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<EvaluationModel> updateEvaluation({
    required String evaluationId,
    String? weekLabel,
    int? overallMark,
    String? feedback,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};
    if (weekLabel != null) body['weekLabel'] = weekLabel;
    if (overallMark != null) body['overallMark'] = overallMark;
    if (feedback != null) body['feedback'] = feedback;

    final response = await _apiService.patch(
      '${ApiConfig.evaluations}/$evaluationId',
      token: token,
      body: body,
    );
    final data = response['data'] ?? response;
    return EvaluationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteEvaluation(String evaluationId) async {
    final token = await _requireToken();
    await _apiService.delete(
      '${ApiConfig.evaluations}/$evaluationId',
      token: token,
    );
  }

  Future<List<EvaluationModel>> getAllEvaluations() async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.evaluations,
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is List) {
      return data
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => EvaluationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token. Please log in again.');
    }
    return token;
  }
}
