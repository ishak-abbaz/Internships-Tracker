import '../config/api_config.dart';
import '../models/department_model.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdminDepartmentService {
  final ApiService _apiService;
  final AuthService _authService;

  AdminDepartmentService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<List<DepartmentModel>> fetchDepartments() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminDepartmentsList, token: token);
    final items = (response['departments'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DepartmentModel> getDepartmentById(String id) async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminDepartmentById(id), token: token);
    return DepartmentModel.fromJson((response['department'] ?? response) as Map<String, dynamic>);
  }

  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
    String? description,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.adminDepartmentsCreate,
      token: token,
      body: {
        'name': name,
        'code': code,
        'description': description ?? '',
      },
    );

    return DepartmentModel.fromJson((response['department'] ?? response) as Map<String, dynamic>);
  }

  Future<DepartmentModel> updateDepartment({
    required String id,
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};

    if (name != null) {
      body['name'] = name;
    }
    if (code != null) {
      body['code'] = code;
    }
    if (description != null) {
      body['description'] = description;
    }
    if (isActive != null) {
      body['is_active'] = isActive;
    }

    final response = await _apiService.patch(
      ApiConfig.adminDepartmentsUpdate(id),
      token: token,
      body: body,
    );

    return DepartmentModel.fromJson((response['department'] ?? response) as Map<String, dynamic>);
  }

  Future<void> deleteDepartment(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminDepartmentsDelete(id), token: token);
  }

  /// Fetches mentors, optionally filtered by department
  Future<List<dynamic>> fetchMentors({String? departmentId}) async {
    final token = await _requireToken();
    String endpoint = ApiConfig.adminMentors;
    
    // Add query parameters
    final Map<String, String> queryParams = {'include': 'department'};
    if (departmentId != null) {
      queryParams['department'] = departmentId;
    }
    
    final queryString = Uri(queryParameters: queryParams).query;
    endpoint = '$endpoint?$queryString';
    
    final response = await _apiService.get(endpoint, token: token);
    final items = (response['mentors'] ?? response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items;
  }

  /// Creates a new mentor
  Future<Map<String, dynamic>> createMentor({
    required String fullName,
    required String email,
    required String password,
    required String departmentId,
    required String specialization,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.adminUsers,
      token: token,
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'user_role': 'Mentor',
        'department_id': departmentId,
        'specialization': specialization,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Updates an existing mentor
  Future<Map<String, dynamic>> updateMentor({
    required String id,
    String? fullName,
    String? email,
    String? departmentId,
    String? specialization,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};
    
    if (fullName != null) body['full_name'] = fullName;
    if (email != null) body['email'] = email;
    if (departmentId != null) body['department_id'] = departmentId;
    if (specialization != null) body['specialization'] = specialization;

    final response = await _apiService.patch(
      ApiConfig.adminMentorsById(id),
      token: token,
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// Deletes a mentor
  Future<void> deleteMentor(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminMentorsById(id), token: token);
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Missing auth token. Please log in again.', statusCode: 401);
    }
    return token;
  }
}
