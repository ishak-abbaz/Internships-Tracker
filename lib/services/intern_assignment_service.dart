import '../config/api_config.dart';
import '../models/intern_assignment_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class InternAssignmentService {
  final ApiService _apiService;
  final AuthService _authService;

  InternAssignmentService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<List<InternAssignmentModel>> fetchAssignments({String? mentorId, String? departmentId}) async {
    final token = await _requireToken();
    final query = <String, String>{};
    if (mentorId != null && mentorId.isNotEmpty) query['mentor_id'] = mentorId;
    if (departmentId != null && departmentId.isNotEmpty) query['department_id'] = departmentId;

    final queryString = query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final response = await _apiService.get(
      '${ApiConfig.adminInternships}$queryString',
      token: token,
    );

    final items = (response['assignments'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => InternAssignmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<InternAssignmentModel> createAssignment({
    required String internId,
    required String mentorName,
    required String departmentCode,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      '${ApiConfig.adminInternships}/$internId',
      token: token,
      body: {
        'mentor_name': mentorName,
        'department_code': departmentCode,
      },
    );

    final data = response['assignment'] ?? response['data'] ?? response;
    return InternAssignmentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateAssignment({
    required String assignmentId,
    String? mentorName,
    String? departmentCode,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};
    if (mentorName != null) body['mentor_name'] = mentorName;
    if (departmentCode != null) body['department_code'] = departmentCode;

    await _apiService.patch(
      '${ApiConfig.adminInternships}/update/$assignmentId',
      token: token,
      body: body,
    );
  }

  Future<void> deleteAssignment(String assignmentId) async {
    final token = await _requireToken();
    await _apiService.delete(
      '${ApiConfig.adminInternships}/$assignmentId',
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
