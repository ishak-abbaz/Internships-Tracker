import 'package:flutter/material.dart';
import '../models/evaluation_model.dart';
import '../services/evaluation_service.dart';
import '../services/api_exception.dart';

class EvaluationNotifier extends ChangeNotifier {
  final EvaluationService _service = EvaluationService();

  List<EvaluationModel> _records = [];
  bool _isLoading = false;
  String? _error;

  List<EvaluationModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getAllEvaluations();
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _records = [];
      } else {
        _error = 'Failed to load evaluations: ${e.toString()}';
      }
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
      _records = await _service.getMentorEvaluations(mentorId);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _records = [];
      } else {
        _error = 'Failed to load evaluations: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForIntern(String internId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getInternEvaluations(internId);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        _records = [];
      } else {
        _error = 'Failed to load evaluations: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvaluation(EvaluationModel evaluation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createEvaluation(evaluation);
      _records = [created, ..._records];
      return true;
    } catch (e) {
      _error = 'Failed to save evaluation: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEvaluation({
    required String evaluationId,
    String? weekLabel,
    int? overallMark,
    String? feedback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateEvaluation(
        evaluationId: evaluationId,
        weekLabel: weekLabel,
        overallMark: overallMark,
        feedback: feedback,
      );
      final index = _records.indexWhere((r) => r.id == evaluationId);
      if (index != -1) {
        _records[index] = updated;
      }
      return true;
    } catch (e) {
      _error = 'Failed to update evaluation: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEvaluation(String evaluationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteEvaluation(evaluationId);
      _records.removeWhere((r) => r.id == evaluationId);
      return true;
    } catch (e) {
      _error = 'Failed to delete evaluation: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
