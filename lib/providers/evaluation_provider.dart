import 'package:flutter/material.dart';
import '../models/evaluation_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class EvaluationNotifier extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<EvaluationModel> _evaluations = [];
  double? _averageMark;
  bool _isLoading = false;
  String? _error;

  List<EvaluationModel> get evaluations => _evaluations;
  List<EvaluationModel> get records => _evaluations;
  double? get averageMark => _averageMark;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInternEvaluations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      final response = await _apiService.get(ApiConfig.internEvaluations, token: token);
      
      final List<dynamic> evalList = response['evaluations'] ?? [];
      _evaluations = evalList.map((json) => EvaluationModel.fromJson(json)).toList();
      _averageMark = (response['average_mark'] as num?)?.toDouble();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      final response = await _apiService.get(ApiConfig.evaluations, token: token);
      final List<dynamic> list = response['data']['data'] ?? [];
      _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
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
      final token = await _authService.getToken();
      final response = await _apiService.get('${ApiConfig.evaluations}/mentor/$mentorId', token: token);
      final List<dynamic> list = response['data']['data'] ?? [];
      _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
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
      final token = await _authService.getToken();
      final response = await _apiService.get('${ApiConfig.evaluations}/intern/$internId', token: token);
      final List<dynamic> list = response['data']['data'] ?? [];
      _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvaluation(EvaluationModel evaluation) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      await _apiService.post(ApiConfig.evaluations, body: evaluation.toJson(), token: token);
      await fetchAll();
      return true;
    } catch (e) {
      _error = e.toString();
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
    notifyListeners();
    try {
      final token = await _authService.getToken();
      await _apiService.patch('${ApiConfig.evaluations}/$evaluationId', body: {
        if (weekLabel != null) 'week_label': weekLabel,
        if (overallMark != null) 'overall_mark': overallMark,
        if (feedback != null) 'feedback': feedback,
      }, token: token);
      await fetchAll();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEvaluation(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      await _apiService.delete('${ApiConfig.evaluations}/$id', token: token);
      _evaluations.removeWhere((e) => e.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
