import 'department_model.dart';

class MentorModel {
  final String id;
  final String fullName;
  final String email;
  final String? departmentId;
  final DepartmentModel? department;
  final String? specialization;

  MentorModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.departmentId,
    this.department,
    this.specialization,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    String? deptId;
    DepartmentModel? deptInfo;

    // Handle 'department' key (legacy or include)
    if (json['department'] is String) {
      deptId = json['department'];
    } else if (json['department'] is Map<String, dynamic>) {
      deptInfo = DepartmentModel.fromJson(json['department']);
      deptId = deptInfo.id;
    }
    
    // Handle 'department_id' key (common in this API)
    if (json['department_id'] is String) {
      deptId = json['department_id'];
    } else if (json['department_id'] is Map<String, dynamic>) {
      deptInfo = DepartmentModel.fromJson(json['department_id']);
      deptId = deptInfo.id;
    }

    return MentorModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      departmentId: deptId,
      department: deptInfo,
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'department': department?.id ?? departmentId,
    'specialization': specialization,
  };
}
