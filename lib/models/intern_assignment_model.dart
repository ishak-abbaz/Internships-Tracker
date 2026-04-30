class InternAssignmentModel {
  final String id;
  final String internId;
  final String mentorId;
  final String departmentId;
  final String assignedByAdminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternAssignmentModel({
    required this.id,
    required this.internId,
    required this.mentorId,
    required this.departmentId,
    required this.assignedByAdminId,
    this.createdAt,
    this.updatedAt,
  });

  factory InternAssignmentModel.fromJson(Map<String, dynamic> json) {
    return InternAssignmentModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      internId: (json['intern_id'] ?? '').toString(),
      mentorId: (json['mentor_id'] ?? '').toString(),
      departmentId: (json['department_id'] ?? '').toString(),
      assignedByAdminId: (json['assigned_by_admin_id'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload({
    required String mentorName,
    required String departmentCode,
  }) {
    return {
      'mentor_name': mentorName,
      'department_code': departmentCode,
    };
  }
}
