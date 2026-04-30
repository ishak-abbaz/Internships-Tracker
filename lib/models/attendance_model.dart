class AttendanceModel {
  final String id;
  final String internId;
  final String mentorId;
  final DateTime attendanceDate;
  final String status;
  final String? notes;
  final String? markedByMentorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.internId,
    required this.mentorId,
    required this.attendanceDate,
    required this.status,
    this.notes,
    this.markedByMentorId,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      internId: (json['intern_id'] ?? '').toString(),
      mentorId: (json['mentor_id'] ?? '').toString(),
      attendanceDate: DateTime.tryParse((json['attendance_date'] ?? '').toString()) ?? DateTime.now(),
      status: (json['status'] ?? 'present').toString(),
      notes: json['notes']?.toString(),
      markedByMentorId: json['marked_by_mentor_id']?.toString(),
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
      'internId': internId,
      'mentorId': mentorId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  AttendanceModel copyWith({
    String? status,
    String? notes,
  }) {
    return AttendanceModel(
      id: id,
      internId: internId,
      mentorId: mentorId,
      attendanceDate: attendanceDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      markedByMentorId: markedByMentorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
