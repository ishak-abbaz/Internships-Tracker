import 'package:flutter/material.dart';
import '../models/training_module_model.dart';
import '../services/training_module_service.dart';
import '../services/api_exception.dart';

class TrainingModuleNotifier extends ChangeNotifier {
  final TrainingModuleService _service = TrainingModuleService();

  List<TrainingModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  List<TrainingModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchForMentor(String mentorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _service.getModulesByMentor(mentorId);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _modules = [];
      } else {
        _error = 'Failed to load modules: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForDepartment(String departmentCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _service.getModulesByDepartment(departmentCode);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _modules = [];
      } else {
        _error = 'Failed to load modules: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createModule({
    required String title,
    required String description,
    required String url,
    required String departmentCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createModule(
        title: title,
        description: description,
        url: url,
        departmentCode: departmentCode,
      );
      _modules = [created, ..._modules];
      return true;
    } catch (e) {
      _error = 'Failed to create module: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateModule({
    required String moduleId,
    String? title,
    String? description,
    String? url,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateModule(
        moduleId: moduleId,
        title: title,
        description: description,
        url: url,
        isActive: isActive,
      );
      final index = _modules.indexWhere((m) => m.id == moduleId);
      if (index != -1) {
        _modules[index] = updated;
      }
      return true;
    } catch (e) {
      _error = 'Failed to update module: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteModule(String moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteModule(moduleId);
      _modules.removeWhere((m) => m.id == moduleId);
      return true;
    } catch (e) {
      _error = 'Failed to delete module: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
