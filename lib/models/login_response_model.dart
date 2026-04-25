import 'user_model.dart';

class LoginResponseModel {
  final String message;
  final String accessToken;
  final UserModel user;

  const LoginResponseModel({
    required this.message,
    required this.accessToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: (json['msg'] ?? '').toString(),
      accessToken: (json['accessToken'] ?? '').toString(),
      user: UserModel.fromJson((json['user'] ?? <String, dynamic>{}) as Map<String, dynamic>),
    );
  }
}
