import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../services/admin_department_service.dart';
import '../services/api_exception.dart';

class CreateInternFormNotifier extends ChangeNotifier {
  final AdminDepartmentService _service = AdminDepartmentService();

  // Departments state
  List<DepartmentModel> _departments = [];
  bool _departmentsLoading = false;
  String? _departmentsError;

  // Mentors state
  List<dynamic> _mentors = [];
  bool _mentorsLoading = false;
  String? _mentorsError;
  String? _selectedDepartmentId;

  // Getters
  List<DepartmentModel> get departments => _departments;
  bool get departmentsLoading => _departmentsLoading;
  String? get departmentsError => _departmentsError;

  List<dynamic> get mentors => _mentors;
  bool get mentorsLoading => _mentorsLoading;
  String? get mentorsError => _mentorsError;
  String? get selectedDepartmentId => _selectedDepartmentId;

  bool get isInitializing => _departmentsLoading;

  /// Fetch departments when dialog opens
  Future<void> initializeFormData() async {
    await fetchDepartments();
  }

  /// Fetch all departments
  Future<void> fetchDepartments() async {
    _departmentsLoading = true;
    _departmentsError = null;
    notifyListeners();

    try {
      _departments = await _service.fetchDepartments();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _departments = [];
      } else {
        _departmentsError = e.message;
      }
    } catch (e) {
      _departmentsError = 'Failed to load departments: ${e.toString()}';
    } finally {
      _departmentsLoading = false;
      notifyListeners();
    }
  }

  /// Fetch mentors for selected department
  Future<void> fetchMentorsByDepartment(String departmentId) async {
    _selectedDepartmentId = departmentId;
    _mentorsLoading = true;
    _mentorsError = null;
    _mentors = [];
    notifyListeners();

    try {
      _mentors = await _service.fetchMentors(departmentId: departmentId);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _mentors = [];
      } else {
        _mentorsError = e.message;
      }
    } catch (e) {
      _mentorsError = 'Failed to load mentors: ${e.toString()}';
    } finally {
      _mentorsLoading = false;
      notifyListeners();
    }
  }

  /// Clear mentors when department is deselected
  void clearMentors() {
    _mentors = [];
    _selectedDepartmentId = null;
    _mentorsError = null;
    notifyListeners();
  }

  void reset() {
    _departments = [];
    _departmentsLoading = false;
    _departmentsError = null;
    _mentors = [];
    _mentorsLoading = false;
    _mentorsError = null;
    _selectedDepartmentId = null;
  }
}
