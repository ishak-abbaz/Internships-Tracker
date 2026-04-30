import 'package:flutter/material.dart';
import '../models/mentor_model.dart';
import '../services/admin_department_service.dart';
import '../services/api_exception.dart';

class AdminMentorsNotifier extends ChangeNotifier {
  final AdminDepartmentService _service = AdminDepartmentService();

  List<MentorModel> _mentors = [];
  List<MentorModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';

  List<MentorModel> get mentors => _query.isEmpty ? _mentors : _filtered;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalMentors => _mentors.length;

  Future<void> fetchMentors({String? departmentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _service.fetchMentors(departmentId: departmentId);
      _mentors = items
          .map((item) => MentorModel.fromJson(item as Map<String, dynamic>))
          .toList();
      _filtered = _mentors;
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _mentors = [];
        _filtered = [];
      } else {
        _error = 'Failed to load mentors: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _query = query.trim();
    if (_query.isEmpty) {
      _filtered = _mentors;
    } else {
      _filtered = _mentors
          .where((m) => m.fullName.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<MentorModel?> createMentor({
    required String fullName,
    required String email,
    required String password,
    required String departmentId,
    required String specialization,
  }) async {
    _error = null;
    try {
      final result = await _service.createMentor(
        fullName: fullName,
        email: email,
        password: password,
        departmentId: departmentId,
        specialization: specialization,
      );
      final mentor = MentorModel.fromJson(result);
      _mentors.add(mentor);
      _filtered = _mentors;
      notifyListeners();
      return mentor;
    } catch (e) {
      _error = 'Failed to create mentor: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<MentorModel?> updateMentor({
    required String id,
    String? fullName,
    String? email,
    String? departmentId,
    String? specialization,
  }) async {
    _error = null;
    try {
      final result = await _service.updateMentor(
        id: id,
        fullName: fullName,
        email: email,
        departmentId: departmentId,
        specialization: specialization,
      );
      
      // Re-fetch mentors to ensure we have the fully populated nested objects
      // (like department codes) since the PATCH response might be partial.
      await fetchMentors();
      
      return _mentors.firstWhere((m) => m.id == id);
    } catch (e) {
      _error = 'Failed to update mentor: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteMentor(String id) async {
    _error = null;
    try {
      await _service.deleteMentor(id);
      _mentors.removeWhere((m) => m.id == id);
      _filtered = _mentors;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete mentor: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
