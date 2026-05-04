import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        // Since we don't have a /me endpoint, we'll need to decide how to handle this.
        // For now, if there's a token, we might need a way to get user info.
        // Option 1: Store user info in SharedPreferences too.
        // Option 2: Add a /me or /profile endpoint to the backend.
        
        final userJson = await _authService.getUser();
        if (userJson != null) {
          _currentUser = UserModel.fromJson(userJson);
        }
      }
    } catch (e) {
      print('Auto-login failed: $e');
      await _authService.clearToken();
      await _authService.clearUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);
      _currentUser = result.user;
      await _authService.saveUser(result.user.toJson());
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unexpected error during login.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    await _authService.clearUser();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
