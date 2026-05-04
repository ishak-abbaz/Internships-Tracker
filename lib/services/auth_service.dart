import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/login_response_model.dart';
import '../models/registration_response_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  final ApiService _apiService;

  AuthService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    final loginResponse = LoginResponseModel.fromJson(response);
    await saveToken(loginResponse.accessToken);
    return loginResponse;
  }

  Future<RegistrationResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await _apiService.post(
      ApiConfig.register,
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
      },
    );

    return RegistrationResponseModel.fromJson(response);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
