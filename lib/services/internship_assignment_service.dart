import '../config/api_config.dart';
import '../models/internship_assignment_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class InternshipAssignmentService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token. Please log in again.');
    }
    return token;
  }

  Future<List<InternshipAssignmentModel>> getAllAssignments() async {
    final token = await _requireToken();
    final response = await _apiService.get(ApiConfig.adminInternships, token: token);
    
    final List<dynamic> items = response['assignments'] ?? [];
    return items.map((item) => InternshipAssignmentModel.fromJson(item)).toList();
  }

  Future<InternshipAssignmentModel> createAssignment({
    required String internId,
    required String mentorId,
    required String departmentId,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.adminInternshipByInternId(internId),
      token: token,
      body: {
        'mentor_id': mentorId,
        'department_id': departmentId,
        'subject': subject,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    final data = response['assignment'] ?? response;
    return InternshipAssignmentModel.fromJson(data);
  }

  Future<InternshipAssignmentModel> updateAssignment(String id, Map<String, dynamic> updateData) async {
    final token = await _requireToken();
    final response = await _apiService.patch(
      ApiConfig.adminInternshipUpdate(id),
      token: token,
      body: updateData,
    );
    final data = response['assignment'] ?? response;
    return InternshipAssignmentModel.fromJson(data);
  }

  Future<void> deleteAssignment(String id) async {
    final token = await _requireToken();
    await _apiService.delete(ApiConfig.adminInternshipDelete(id), token: token);
  }

  Future<InternshipAssignmentModel?> getMyAssignment() async {
    final token = await _requireToken();
    try {
      final response = await _apiService.get(ApiConfig.internAssignment, token: token);
      final data = response['assignment'];
      if (data == null) return null;
      return InternshipAssignmentModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
