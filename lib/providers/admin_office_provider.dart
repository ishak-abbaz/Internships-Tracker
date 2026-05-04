import 'dart:io';
import 'package:flutter/material.dart';
import '../models/admin_office_models.dart';
import '../services/admin_office_service.dart';
import '../services/api_exception.dart';

class AdminOfficeNotifier extends ChangeNotifier {
  final AdminOfficeService _service;

  AdminOfficeNotifier({AdminOfficeService? service})
      : _service = service ?? AdminOfficeService();

  List<PolicyHandbook> _policies = [];
  List<OfficeSchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<PolicyHandbook> get policies => _policies;
  List<OfficeSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPolicies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _policies = await _service.fetchPolicies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _service.fetchSchedules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPolicy({
    required String title,
    String? description,
    String? version,
    String? departmentId,
    File? file,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newPolicy = await _service.createPolicy(
        title: title,
        description: description,
        version: version,
        departmentId: departmentId,
        file: file,
      );
      _policies.insert(0, newPolicy);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePolicy(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedPolicy = await _service.updatePolicy(id, data);
      final index = _policies.indexWhere((p) => p.id == id);
      if (index != -1) {
        _policies[index] = updatedPolicy;
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

  Future<bool> deletePolicy(String id) async {
    try {
      await _service.deletePolicy(id);
      _policies.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createSchedule({
    required String title,
    String? departmentId,
    String? academicYear,
    String? group,
    String? teacherName,
    String? moduleName,
    File? file,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newSchedule = await _service.createSchedule(
        title: title,
        departmentId: departmentId,
        academicYear: academicYear,
        group: group,
        teacherName: teacherName,
        moduleName: moduleName,
        file: file,
      );
      _schedules.insert(0, newSchedule);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      await _service.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
