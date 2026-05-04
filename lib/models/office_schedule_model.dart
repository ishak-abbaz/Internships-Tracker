class OfficeScheduleModel {
  final String id;
  final String title;
  final String? description;
  final String? departmentCode;
  final int? version;
  final String? departmentId;
  final String? internId;
  final String? mentorId;
  final String? weekday;
  final String? scheduleDate;
  final String? startTime;
  final String? endTime;
  final String? notes;
  final bool isActive;
  final String? fileUrl;
  final String? createdAt;
  final String? updatedAt;

  const OfficeScheduleModel({
    required this.id,
    required this.title,
    this.description,
    this.departmentCode,
    this.version,
    this.departmentId,
    this.internId,
    this.mentorId,
    this.weekday,
    this.scheduleDate,
    this.startTime,
    this.endTime,
    this.notes,
    required this.isActive,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory OfficeScheduleModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawVersion = json['version'];
    final parsedDescription =
        (json['Description'] ?? json['description'] ?? json['notes'])?.toString();
    return OfficeScheduleModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: parsedDescription == null || parsedDescription.trim().isEmpty
          ? null
          : parsedDescription,
      departmentCode: (json['department_code'] ?? '').toString().isEmpty
          ? null
          : (json['department_code']).toString(),
      version: rawVersion is int ? rawVersion : int.tryParse(rawVersion?.toString() ?? ''),
      departmentId: json['department_id']?.toString(),
      internId: json['intern_id']?.toString(),
      mentorId: json['mentor_id']?.toString(),
      weekday: json['weekday']?.toString(),
      scheduleDate: json['schedule_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      notes: json['notes']?.toString(),
      isActive: json['is_active'] == null ? true : json['is_active'] == true,
      fileUrl: (json['file_url'] ?? json['url'] ?? json['file'] ?? '').toString().isEmpty
          ? null
          : (json['file_url'] ?? json['url'] ?? json['file']).toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
