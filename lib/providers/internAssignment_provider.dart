import 'package:flutter/material.dart';
import '../models/intern_assignment_model.dart';
import '../services/intern_assignment_service.dart';
import '../services/api_exception.dart';

class InternAssignmentNotifier extends ChangeNotifier {
  final InternAssignmentService _service = InternAssignmentService();

  List<InternAssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _error;

  List<InternAssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAssignments({String? mentorId, String? departmentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignments = await _service.fetchAssignments(
        mentorId: mentorId,
        departmentId: departmentId,
      );
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _assignments = [];
      } else {
        _error = 'Failed to load assignments: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssignment({
    required String internId,
    required String mentorName,
    required String departmentCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createAssignment(
        internId: internId,
        mentorName: mentorName,
        departmentCode: departmentCode,
      );
      _assignments = [created, ..._assignments];
      return true;
    } catch (e) {
      _error = 'Failed to create assignment: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssignment({
    required String assignmentId,
    String? mentorName,
    String? departmentCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateAssignment(
        assignmentId: assignmentId,
        mentorName: mentorName,
        departmentCode: departmentCode,
      );
      return true;
    } catch (e) {
      _error = 'Failed to update assignment: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAssignment(String assignmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteAssignment(assignmentId);
      _assignments.removeWhere((a) => a.id == assignmentId);
      return true;
    } catch (e) {
      _error = 'Failed to delete assignment: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
