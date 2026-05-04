class AttendanceModel {
  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final DateTime attendanceDate;
  final String status;
  final String? notes;
  final String? markedByMentorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    required this.attendanceDate,
    required this.status,
    this.notes,
    this.markedByMentorId,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    String internId = '';
    String? internName;
    String mentorId = '';
    String? mentorName;

    if (json['intern_id'] is Map) {
      internId = (json['intern_id']['_id'] ?? '').toString();
      internName = json['intern_id']['full_name']?.toString();
    } else {
      internId = (json['intern_id'] ?? '').toString();
    }

    if (json['mentor_id'] is Map) {
      mentorId = (json['mentor_id']['_id'] ?? '').toString();
      mentorName = json['mentor_id']['full_name']?.toString();
    } else {
      mentorId = (json['mentor_id'] ?? '').toString();
    }

    return AttendanceModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      internId: internId,
      internName: internName,
      mentorId: mentorId,
      mentorName: mentorName,
      attendanceDate: DateTime.tryParse((json['attendance_date'] ?? '').toString()) ?? DateTime.now(),
      status: (json['status'] ?? 'present').toString(),
      notes: json['notes']?.toString(),
      markedByMentorId: json['marked_by_mentor_id'] is Map 
          ? (json['marked_by_mentor_id']['_id'] ?? '').toString()
          : json['marked_by_mentor_id']?.toString(),
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
    String? internName,
    String? mentorName,
  }) {
    return AttendanceModel(
      id: id,
      internId: internId,
      internName: internName ?? this.internName,
      mentorId: mentorId,
      mentorName: mentorName ?? this.mentorName,
      attendanceDate: attendanceDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      markedByMentorId: markedByMentorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
