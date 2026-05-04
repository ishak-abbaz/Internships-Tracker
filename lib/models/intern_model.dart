class InternModel {
  final String id;
  final String fullName;
  final String email;
  final String registrationNr;
  final String? department;
  final String? departmentId;
  final String? departmentCode;
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
    this.departmentCode,
    this.mentor,
    this.mentorId,
    required this.account_status,
    required this.userRole,
  });

  factory InternModel.fromJson(Map<String, dynamic> json) {
    String? deptName;
    String? deptId;
    String? deptCode;
    
    final deptData = json['department_id'];
    if (deptData is Map<String, dynamic>) {
      deptName = (deptData['name'] ?? '').toString();
      deptId = (deptData['_id'] ?? deptData['id'] ?? '').toString();
      deptCode = deptData['code']?.toString();
    } else {
      deptName = json['department']?.toString();
      deptId = json['department_id']?.toString();
    }

    String? mentorName;
    String? mId;
    final mentorData = json['mentor_id'];
    if (mentorData is Map<String, dynamic>) {
      mentorName = (mentorData['full_name'] ?? mentorData['fullName'] ?? '').toString();
      mId = (mentorData['_id'] ?? mentorData['id'] ?? '').toString();
    } else {
      mentorName = json['mentor']?.toString();
      mId = json['mentor_id']?.toString();
    }

    return InternModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      registrationNr: (json['registration_nr'] ?? json['studentNr'] ?? '').toString(),
      department: deptName,
      departmentId: deptId,
      departmentCode: deptCode,
      mentor: mentorName,
      mentorId: mId,
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
      'department_code': departmentCode,
      'mentor': mentor,
      'mentor_id': mentorId,
      'account_status': account_status,
      'user_role': userRole,
    };
  }
}
