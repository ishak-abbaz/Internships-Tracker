import 'dart:io';
import '../config/api_config.dart';
import '../models/admin_office_models.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdminOfficeService {
  final ApiService _apiService;
  final AuthService _authService;

  AdminOfficeService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  // Policy Handbook Methods
  Future<List<PolicyHandbook>> fetchPolicies() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminOfficePolicy, token: token);
    final items = (response['handbooks'] ?? response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => PolicyHandbook.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PolicyHandbook> createPolicy({
    required String title,
    String? description,
    String? version,
    String? departmentId,
    File? file,
  }) async {
    final token = await _requireToken();
    
    Map<String, dynamic> response;
    if (file != null) {
      response = await _apiService.postMultipart(
        ApiConfig.adminOfficePolicyCreate,
        token: token,
        fields: {
          'title': title,
          if (description != null) 'description': description,
          'version': version ?? 'v1.0',
          if (departmentId != null) 'department_id': departmentId,
        },
        file: file,
        fileFieldName: 'file',
      );
    } else {
      response = await _apiService.post(
        ApiConfig.adminOfficePolicyCreate,
        token: token,
        body: {
          'title': title,
          'description': description,
          'version': version ?? 'v1.0',
          'department_id': departmentId,
        },
      );
    }
    
    return PolicyHandbook.fromJson((response['handbook'] ?? response['data'] ?? response) as Map<String, dynamic>);
  }

  Future<void> deletePolicy(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminOfficePolicyDelete(id), token: token);
  }

  // Office Schedule Methods
  Future<List<OfficeSchedule>> fetchSchedules() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminOfficeSchedule, token: token);
    final items = (response['schedules'] ?? response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => OfficeSchedule.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OfficeSchedule> createSchedule({
    required String title,
    String? departmentId,
    String? academicYear,
    String? group,
    String? teacherName,
    String? moduleName,
    File? file,
  }) async {
    final token = await _requireToken();

    Map<String, dynamic> response;
    if (file != null) {
      response = await _apiService.postMultipart(
        ApiConfig.adminOfficeScheduleCreate,
        token: token,
        fields: {
          'title': title,
          if (departmentId != null) 'department_id': departmentId,
          if (academicYear != null) 'academic_year': academicYear,
          if (group != null) 'group': group,
          if (teacherName != null) 'teacher_name': teacherName,
          if (moduleName != null) 'module_name': moduleName,
        },
        file: file,
        fileFieldName: 'file',
      );
    } else {
      response = await _apiService.post(
        ApiConfig.adminOfficeScheduleCreate,
        token: token,
        body: {
          'title': title,
          'department_id': departmentId,
          'academic_year': academicYear,
          'group': group,
          'teacher_name': teacherName,
          'module_name': moduleName,
        },
      );
    }

    return OfficeSchedule.fromJson((response['schedule'] ?? response['data'] ?? response) as Map<String, dynamic>);
  }

  Future<void> deleteSchedule(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminOfficeScheduleDelete(id), token: token);
  }

  Future<PolicyHandbook> updatePolicy(String id, Map<String, dynamic> data) async {
    final token = await _requireToken();
    final response = await _apiService.put(ApiConfig.adminOfficePolicyUpdate(id), body: data, token: token);
    return PolicyHandbook.fromJson((response['handbook'] ?? response['data'] ?? response) as Map<String, dynamic>);
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Missing auth token. Please log in again.', statusCode: 401);
    }
    return token;
  }
}
