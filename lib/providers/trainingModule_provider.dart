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

  Future<void> fetchAllAdmin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _service.getAllModules();
    } catch (e) {
      _error = 'Failed to load modules: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForIntern() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _service.getInternModules();
    } catch (e) {
      _error = 'Failed to load modules: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    required String departmentCode,
    required String url,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newModule = TrainingModuleModel(
        id: '',
        title: title,
        description: description,
        url: url,
        departmentCode: departmentCode,
        createdByMentorId: '',
        isActive: true,
      );
      final created = await _service.createModule(newModule);
      _modules = [created, ..._modules];
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to create module';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateModule(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateModule(id, updates);
      final index = _modules.indexWhere((m) => m.id == id);
      if (index != -1) {
        _modules[index] = updated;
      }
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to update module';
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
      _error = e is ApiException ? e.message : 'Failed to delete module';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsComplete(String moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markAsComplete(moduleId);
      final index = _modules.indexWhere((m) => m.id == moduleId);
      if (index != -1) {
        final old = _modules[index];
        _modules[index] = TrainingModuleModel(
          id: old.id,
          title: old.title,
          description: old.description,
          url: old.url,
          departmentCode: old.departmentCode,
          createdByMentorId: old.createdByMentorId,
          mentorEmail: old.mentorEmail,
          isActive: old.isActive,
          isCompleted: true,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
      }
      return true;
    } catch (e) {
      _error = 'Failed to mark as complete: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
