class InternModel {
  final String id;
  final String fullName;
  final String email;
  final String registrationNr;
  final String? department;
  final String? departmentId;
  final String? mentor;
  final String? mentorId;
  final String account_status;
  final String userRole;

  const InternModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.registrationNr,
    this.department,
    this.departmentId,
    this.mentor,
    this.mentorId,
    required this.account_status,
    required this.userRole,
  });

  factory InternModel.fromJson(Map<String, dynamic> json) {
    return InternModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      registrationNr: (json['registration_nr'] ?? json['studentNr'] ?? '').toString(),
      department: json['department']?.toString(),
      departmentId: json['department_id']?.toString(),
      mentor: json['mentor']?.toString(),
      mentorId: json['mentor_id']?.toString(),
      account_status: (json['account_status'] ?? 'Active').toString(),
      userRole: (json['user_role'] ?? 'intern').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'registration_nr': registrationNr,
      'department': department,
      'department_id': departmentId,
      'mentor': mentor,
      'mentor_id': mentorId,
      'account_status': account_status,
      'user_role': userRole,
    };
  }
}
