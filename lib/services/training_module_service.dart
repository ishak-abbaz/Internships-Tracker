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

  Future<List<TrainingModuleModel>> getAllModules() async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.trainingModules,
      token: token,
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => TrainingModuleModel.fromJson(json)).toList();
  }

  Future<List<TrainingModuleModel>> getModulesByDepartment(String departmentCode) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.trainingModulesByDepartment(departmentCode),
      token: token,
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => TrainingModuleModel.fromJson(json)).toList();
  }

  Future<List<TrainingModuleModel>> getModulesByMentor(String mentorId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.trainingModulesByMentor(mentorId),
      token: token,
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => TrainingModuleModel.fromJson(json)).toList();
  }
  
  // For Interns
  Future<List<TrainingModuleModel>> getInternModules() async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.internTrainingModules,
      token: token,
    );
    final List<dynamic> data = response['data'] ?? response['modules'] ?? [];
    return data.map((json) => TrainingModuleModel.fromJson(json)).toList();
  }

  Future<TrainingModuleModel> createModule(TrainingModuleModel module) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.trainingModules,
      token: token,
      body: module.toJson(),
    );
    final data = response['data'] ?? response;
    return TrainingModuleModel.fromJson(data);
  }

  Future<TrainingModuleModel> updateModule(String id, Map<String, dynamic> updates) async {
    final token = await _requireToken();
    final response = await _apiService.patch(
      ApiConfig.trainingModuleById(id),
      token: token,
      body: updates,
    );
    final data = response['data'] ?? response;
    return TrainingModuleModel.fromJson(data);
  }

  Future<void> deleteModule(String id) async {
    final token = await _requireToken();
    await _apiService.delete(
      ApiConfig.trainingModuleById(id),
      token: token,
    );
  }

  Future<void> markAsComplete(String moduleId) async {
    final token = await _requireToken();
    await _apiService.post(
      '${ApiConfig.internTrainingModules}/$moduleId/complete',
      token: token,
    );
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Authentication required');
    return token;
  }
}
