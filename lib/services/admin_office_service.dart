import '../config/api_config.dart';
import '../models/office_schedule_model.dart';
import '../models/policy_document_model.dart';
import 'package:http_parser/http_parser.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdminOfficeService {
  final ApiService _apiService;
  final AuthService _authService;

  AdminOfficeService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<List<PolicyDocumentModel>> fetchPolicies() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminOfficePoliciesList, token: token);
    final items = (response['policies'] ?? response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => PolicyDocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OfficeScheduleModel>> fetchSchedules() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminOfficeSchedulesList, token: token);
    final items = (response['schedules'] ?? response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => OfficeScheduleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OfficeScheduleModel> getScheduleById(String id) async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminOfficeScheduleById(id), token: token);
    final schedule = (response['schedule'] ?? response['data'] ?? response) as Map<String, dynamic>;
    return OfficeScheduleModel.fromJson(schedule);
  }

  Future<PolicyDocumentModel> uploadPolicy({
    required String title,
    required List<int> fileBytes,
    required String fileName,
    String? description,
    String? departmentCode,
    String? targetRole,
    int? version,
  }) async {
    final token = await _requireToken();
    final fields = <String, String>{
      'title': title,
    };

    if (description != null && description.trim().isNotEmpty) {
      fields['description'] = description.trim();
    }
    if (departmentCode != null && departmentCode.trim().isNotEmpty) {
      fields['department_code'] = departmentCode.trim();
    }
    if (targetRole != null && targetRole.trim().isNotEmpty) {
      fields['target_role'] = targetRole.trim();
    }
    if (version != null) {
      fields['version'] = version.toString();
    }

    final response = await _apiService.post(
      ApiConfig.adminOfficePoliciesCreate,
      token: token,
      multipartFields: fields,
      multipartFileBytes: fileBytes,
      multipartFileField: 'file',
      multipartFileName: fileName,
      multipartFileContentType: MediaType('application', 'pdf'),
    );

    final policy = (response['policy'] ?? response['data'] ?? response) as Map<String, dynamic>;
    return PolicyDocumentModel.fromJson(policy);
  }

  Future<PolicyDocumentModel> updatePolicy({
    required String id,
    String? title,
    String? description,
    String? departmentCode,
    String? targetRole,
    int? version,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final token = await _requireToken();
    final fields = <String, String>{};

    if (title != null && title.trim().isNotEmpty) {
      fields['title'] = title.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      fields['description'] = description.trim();
    }
    if (departmentCode != null && departmentCode.trim().isNotEmpty) {
      fields['department_code'] = departmentCode.trim();
    }
    if (targetRole != null && targetRole.trim().isNotEmpty) {
      fields['target_role'] = targetRole.trim();
    }
    if (version != null) {
      fields['version'] = version.toString();
    }

    final response = await _apiService.patch(
      ApiConfig.adminOfficePoliciesUpdate(id),
      token: token,
      multipartFields: fields,
      multipartFileBytes: fileBytes,
      multipartFileField: 'file',
      multipartFileName: fileName,
      multipartFileContentType: fileBytes == null ? null : MediaType('application', 'pdf'),
    );

    final policy = (response['policy'] ?? response['data'] ?? response) as Map<String, dynamic>;
    return PolicyDocumentModel.fromJson(policy);
  }

  Future<void> deletePolicy(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminOfficePoliciesDelete(id), token: token);
  }

  Future<OfficeScheduleModel> uploadSchedule({
    String? title,
    required List<int> fileBytes,
    required String fileName,
    String? description,
    String? departmentCode,
    int? version,
  }) async {
    final token = await _requireToken();
    final normalizedTitle = (title ?? '').trim();
    final fields = <String, String>{
      // Compatibility fallback: current deployed backend still validates these keys.
      'title': normalizedTitle.isEmpty ? 'Schedule' : normalizedTitle,
      'start_time': '09:00',
      'end_time': '17:00',
    };

    if (description != null && description.trim().isNotEmpty) {
      fields['Description'] = description.trim();
      fields['notes'] = description.trim();
    }
    if (departmentCode != null && departmentCode.trim().isNotEmpty) {
      fields['department_code'] = departmentCode.trim();
    }
    if (version != null) {
      fields['version'] = version.toString();
    }

    final response = await _apiService.post(
      ApiConfig.adminOfficeSchedulesCreate,
      token: token,
      multipartFields: fields,
      multipartFileBytes: fileBytes,
      multipartFileField: 'file',
      multipartFileName: fileName,
      multipartFileContentType: MediaType('application', 'pdf'),
    );

    final schedule = (response['schedule'] ?? response['data'] ?? response) as Map<String, dynamic>;
    return OfficeScheduleModel.fromJson(schedule);
  }

  Future<OfficeScheduleModel> updateSchedule({
    required String id,
    String? title,
    String? description,
    String? departmentCode,
    int? version,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final token = await _requireToken();
    final fields = <String, String>{};

    if (title != null && title.trim().isNotEmpty) {
      fields['title'] = title.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      fields['Description'] = description.trim();
      fields['description'] = description.trim();
      fields['notes'] = description.trim();
    }
    if (departmentCode != null && departmentCode.trim().isNotEmpty) {
      fields['department_code'] = departmentCode.trim();
    }
    if (version != null) {
      fields['version'] = version.toString();
    }

    final response = await _apiService.patch(
      ApiConfig.adminOfficeSchedulesUpdate(id),
      token: token,
      multipartFields: fields,
      multipartFileBytes: fileBytes,
      multipartFileField: 'file',
      multipartFileName: fileName,
      multipartFileContentType: fileBytes == null ? null : MediaType('application', 'pdf'),
    );

    final schedule = (response['schedule'] ?? response['data'] ?? response) as Map<String, dynamic>;
    return OfficeScheduleModel.fromJson(schedule);
  }

  Future<void> deleteSchedule(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminOfficeSchedulesDelete(id), token: token);
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Missing auth token. Please log in again.', statusCode: 401);
    }
    return token;
  }
}
