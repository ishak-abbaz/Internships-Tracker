import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../services/admin_department_service.dart';
import '../services/api_exception.dart';

class AdminDepartmentsNotifier extends ChangeNotifier {
  final AdminDepartmentService _service = AdminDepartmentService();

  List<DepartmentModel> _departments = [];
  bool _isLoading = false;
  String? _error;

  List<DepartmentModel> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _service.fetchDepartments();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _departments = [];
      } else {
        _error = e.message;
      }
    } catch (e) {
      _error = 'Unable to load departments.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DepartmentModel?> createDepartment({
    required String name,
    required String code,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDept = await _service.createDepartment(
        name: name,
        code: code,
        description: description,
      );
      _departments.insert(0, newDept);
      return newDept;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Unable to create department.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DepartmentModel?> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? description,
    required bool isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDept = await _service.updateDepartment(
        id: id,
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
      final index = _departments.indexWhere((d) => d.id == id);
      if (index != -1) {
        _departments[index] = updatedDept;
      }
      return updatedDept;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Unable to update department.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDepartment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDepartment(id);
      _departments.removeWhere((d) => d.id == id);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Unable to delete department.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
