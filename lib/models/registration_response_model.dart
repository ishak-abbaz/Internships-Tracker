import 'user_model.dart';

class RegistrationResponseModel {
  final String message;
  final UserModel user;

  const RegistrationResponseModel({
    required this.message,
    required this.user,
  });

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      message: (json['msg'] ?? '').toString(),
      user: UserModel.fromJson((json['user'] ?? <String, dynamic>{}) as Map<String, dynamic>),
    );
  }
}
