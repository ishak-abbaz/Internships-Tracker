class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? createdByAdminId;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdByAdminId,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      description: json['description']?.toString(),
      createdByAdminId: json['created_by_admin_id']?.toString(),
      isActive: json['is_active'] == null ? true : json['is_active'] == true,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? createdByAdminId,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByAdminId: createdByAdminId ?? this.createdByAdminId,
    );
  }
}
