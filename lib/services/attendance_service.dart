import '../config/api_config.dart';
import '../models/attendance_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AttendanceService {
  final ApiService _apiService;
  final AuthService _authService;

  AttendanceService({ApiService? apiService, AuthService? authService})
      : _apiService = apiService ?? ApiService(),
        _authService = authService ?? AuthService();

  Future<AttendanceModel> createAttendance(AttendanceModel attendance) async {
    final token = await _requireToken();
    final response = await _apiService.post(
      ApiConfig.mentorAttendance,
      token: token,
      body: attendance.toCreatePayload(),
    );

    final data = response['data'] ?? response;
    return AttendanceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AttendanceModel>> getAttendanceByDate(String dateIso) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.mentorAttendance}/date/$dateIso',
      token: token,
    );
    final items = (response['data'] ?? <dynamic>[]) as List<dynamic>;
    return items
        .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> getInternAttendances(String internId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      '${ApiConfig.mentorAttendance}/intern/$internId',
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is List) {
      return data
          .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<AttendanceModel> updateAttendance({
    required String attendanceId,
    String? status,
    String? notes,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (notes != null) body['notes'] = notes;

    final response = await _apiService.patch(
      '${ApiConfig.mentorAttendance}/$attendanceId',
      token: token,
      body: body,
    );
    final data = response['data'] ?? response;
    return AttendanceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteAttendance(String attendanceId) async {
    final token = await _requireToken();
    await _apiService.delete(
      '${ApiConfig.mentorAttendance}/$attendanceId',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getAttendanceStats(String internId) async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.mentorAttendanceStats(internId),
      token: token,
    );
    return (response['data'] ?? response) as Map<String, dynamic>;
  }

  Future<List<AttendanceModel>> getAllAttendances() async {
    final token = await _requireToken();
    final response = await _apiService.get(
      ApiConfig.mentorAttendance,
      token: token,
    );
    
    // Based on the response structure provided: {"data": {"data": [...]}}
    final wrapper = response['data'] ?? response;
    final items = (wrapper['data'] ?? <dynamic>[]) as List<dynamic>;
    
    return items
        .map((item) => AttendanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> _requireToken() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token. Please log in again.');
    }
    return token;
  }
}
