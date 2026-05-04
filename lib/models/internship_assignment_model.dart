class InternshipAssignmentModel {
  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final String departmentId;
  final String? departmentName;
  final String subject;
  final DateTime startDate;
  final DateTime endDate;
  final String? assignedByAdminId;
  final String? assignedByAdminName;
  final String? id_photo_url;
  final DateTime? createdAt;

  const InternshipAssignmentModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    required this.departmentId,
    this.departmentName,
    required this.subject,
    required this.startDate,
    required this.endDate,
    this.assignedByAdminId,
    this.assignedByAdminName,
    this.id_photo_url,
    this.createdAt,
  });

  factory InternshipAssignmentModel.fromJson(Map<String, dynamic> json) {
    return InternshipAssignmentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      internId: json['intern_id'] is Map ? json['intern_id']['_id'] : json['intern_id']?.toString() ?? '',
      internName: json['intern_id'] is Map ? json['intern_id']['full_name'] : null,
      mentorId: json['mentor_id'] is Map ? json['mentor_id']['_id'] : json['mentor_id']?.toString() ?? '',
      mentorName: json['mentor_id'] is Map ? json['mentor_id']['full_name'] : null,
      departmentId: json['department_id'] is Map ? json['department_id']['_id'] : json['department_id']?.toString() ?? '',
      departmentName: json['department_id'] is Map ? (json['department_id']['name'] ?? json['department_id']['code']) : null,
      subject: json['subject']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      assignedByAdminId: json['assigned_by_admin_id'] is Map ? json['assigned_by_admin_id']['_id'] : json['assigned_by_admin_id']?.toString(),
      assignedByAdminName: json['assigned_by_admin_id'] is Map ? json['assigned_by_admin_id']['full_name'] : null,
      id_photo_url: json['id_photo_url'] ?? (json['intern_id'] is Map ? json['intern_id']['id_photo_url'] : null),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intern_id': internId,
      'mentor_id': mentorId,
      'department_id': departmentId,
      'subject': subject,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
