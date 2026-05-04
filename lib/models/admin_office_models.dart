class PolicyHandbook {
  final String id;
  final String title;
  final String? description;
  final String? fileUrl;
  final String version;
  final bool isActive;
  final DateTime? createdAt;

  PolicyHandbook({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.version,
    required this.isActive,
    this.createdAt,
  });

  factory PolicyHandbook.fromJson(Map<String, dynamic> json) {
    return PolicyHandbook(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['fileUrl'] ?? json['file'],
      version: json['version'] ?? 'v1.0',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class OfficeSchedule {
  final String id;
  final String title;
  final String? departmentId;
  final String? departmentName;
  final String? academicYear;
  final String? group;
  final String? teacherName;
  final String? moduleName;
  final String? fileUrl;
  final DateTime? createdAt;

  OfficeSchedule({
    required this.id,
    required this.title,
    this.departmentId,
    this.departmentName,
    this.academicYear,
    this.group,
    this.teacherName,
    this.moduleName,
    this.fileUrl,
    this.createdAt,
  });

  factory OfficeSchedule.fromJson(Map<String, dynamic> json) {
    return OfficeSchedule(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      departmentId: json['department_id']?['_id'] ?? json['department_id'],
      departmentName: json['department_id']?['name'],
      academicYear: json['academic_year'] ?? json['academicYear'],
      group: json['group'],
      teacherName: json['teacher_name'] ?? json['teacherName'],
      moduleName: json['module_name'] ?? json['moduleName'],
      fileUrl: json['fileUrl'] ?? json['file'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
