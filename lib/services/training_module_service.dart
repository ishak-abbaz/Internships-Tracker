import '../config/api_config.dart';
import '../models/training_module_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TrainingModuleService {
  final ApiService _apiService;
  final AuthService _authService;

  TrainingModuleService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<TrainingModuleModel> createModule({
    required String title,
    required String description,
    required String url,
    required String departmentCode,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.mentorTrainingModules,
      token: token,
      body: {
        'title': title,
        'description': description,
        'url': url,
        'departmentCode': departmentCode,
      },
    );
    final data = response['data'] ?? response;
    return TrainingModuleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TrainingModuleModel>> getModulesByDepartment(String departmentCode) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.mentorTrainingModules}/department/$departmentCode?activeOnly=true',
      token: token,
    );
    final items = (response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => TrainingModuleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrainingModuleModel>> getModulesByMentor(String mentorId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.mentorTrainingModules}/mentor/$mentorId',
      token: token,
    );
    final items = (response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => TrainingModuleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TrainingModuleModel> updateModule({
    required String moduleId,
    String? title,
    String? description,
    String? url,
    bool? isActive,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (url != null) body['url'] = url;
    if (isActive != null) body['is_active'] = isActive;

    final response = await _apiService.patch(
      '${ApiConfig.mentorTrainingModules}/$moduleId',
      token: token,
      body: body,
    );

    final data = response['data'] ?? response;
    return TrainingModuleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteModule(String moduleId) async {
    final token = await _requireToken();
    await _apiService.delete(
      '${ApiConfig.mentorTrainingModules}/$moduleId',
      token: token,
    );
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token. Please log in again.');
    }
    return token;
  }
}
