import 'package:flutter/material.dart';
import '../models/create_intern_response.dart';
import '../services/adminInterns_service.dart';

class CreateInternNotifier extends ChangeNotifier {
  final AdminInternsService _service = AdminInternsService();

  bool _isLoading = false;
  String? _error;
  bool _success = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get success => _success;
  String? get message => _message;

  Future<bool> createIntern({
    required String fullName,
    required String email,
    required String password,
    String? department,
    String? mentor,
  }) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final response = await _service.createIntern(
        fullName: fullName,
        email: email,
        password: password,
        department: department,
        mentor: mentor,
      );

      if (response.success) {
        _success = true;
        _message = response.message;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating intern: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _isLoading = false;
    _error = null;
    _success = false;
    _message = null;
    notifyListeners();
  }
}

