class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String userRole;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userRole,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userRole: (json['user_role'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'user_role': userRole,
    };
  }
}
