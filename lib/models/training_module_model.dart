class TrainingModuleModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String departmentCode;
  final String createdByMentorId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TrainingModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.departmentCode,
    required this.createdByMentorId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingModuleModel.fromJson(Map<String, dynamic> json) {
    return TrainingModuleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      departmentCode: (json['department_code'] ?? '').toString(),
      createdByMentorId: (json['created_by_mentor_id'] ?? '').toString(),
      isActive: (json['is_active'] ?? true) == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'departmentCode': departmentCode,
    };
  }
}
