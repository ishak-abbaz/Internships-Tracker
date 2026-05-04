import 'package:flutter/material.dart';
import '../models/internship_assignment_model.dart';
import '../services/internship_assignment_service.dart';

class InternshipAssignmentNotifier extends ChangeNotifier {
  final InternshipAssignmentService _service = InternshipAssignmentService();

  List<InternshipAssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _error;

  List<InternshipAssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAssignments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignments = await _service.getAllAssignments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssignment({
    required String internId,
    required String mentorId,
    required String departmentId,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAssignment = await _service.createAssignment(
        internId: internId,
        mentorId: mentorId,
        departmentId: departmentId,
        subject: subject,
        startDate: startDate,
        endDate: endDate,
      );
      _assignments.insert(0, newAssignment);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssignment(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateAssignment(id, data);
      final index = _assignments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _assignments[index] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAssignment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteAssignment(id);
      _assignments.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  InternshipAssignmentModel? _myAssignment;
  InternshipAssignmentModel? get myAssignment => _myAssignment;

  Future<void> fetchMyAssignment() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myAssignment = await _service.getMyAssignment();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
