class TrainingModuleModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String departmentCode;
  final String createdByMentorId;
  final String? mentorEmail;
  final bool isActive;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TrainingModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.departmentCode,
    required this.createdByMentorId,
    this.mentorEmail,
    required this.isActive,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingModuleModel.fromJson(Map<String, dynamic> json) {
    String mentorId = '';
    String? email;
    
    final mentorData = json['created_by_mentor_id'];
    if (mentorData is Map) {
      mentorId = (mentorData['_id'] ?? '').toString();
      email = mentorData['email']?.toString();
    } else {
      mentorId = (mentorData ?? '').toString();
    }

    return TrainingModuleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      departmentCode: (json['department_code'] ?? '').toString(),
      createdByMentorId: mentorId,
      mentorEmail: email,
      isActive: (json['is_active'] ?? true) == true,
      isCompleted: (json['is_completed'] ?? false) == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'departmentCode': departmentCode,
      'is_active': isActive,
    };
  }
}
