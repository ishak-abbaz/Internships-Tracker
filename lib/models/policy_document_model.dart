class PolicyDocumentModel {
  final String id;
  final String title;
  final String? description;
  final String? departmentCode;
  final String? targetRole;
  final int? version;
  final bool isActive;
  final String? fileUrl;
  final String? createdAt;
  final String? updatedAt;

  const PolicyDocumentModel({
    required this.id,
    required this.title,
    this.description,
    this.departmentCode,
    this.targetRole,
    this.version,
    required this.isActive,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PolicyDocumentModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawVersion = json['version'];
    return PolicyDocumentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      departmentCode: json['department_code']?.toString(),
      targetRole: json['target_role']?.toString(),
      version: rawVersion is int ? rawVersion : int.tryParse(rawVersion?.toString() ?? ''),
      isActive: json['is_active'] == null ? true : json['is_active'] == true,
      fileUrl: (json['file_url'] ?? json['url'] ?? json['file'] ?? '').toString().isEmpty
          ? null
          : (json['file_url'] ?? json['url'] ?? json['file']).toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
