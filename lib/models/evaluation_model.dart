class EvaluationModel {
  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final String? weekLabel;
  final int overallMark;
  final String? feedback;
  final DateTime? evaluatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EvaluationModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    this.weekLabel,
    required this.overallMark,
    this.feedback,
    this.evaluatedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
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

    return EvaluationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      internId: internId,
      internName: internName,
      mentorId: mentorId,
      mentorName: mentorName,
      weekLabel: json['week_label']?.toString(),
      overallMark: (json['overall_mark'] as num?)?.toInt() ?? 0,
      feedback: json['feedback']?.toString(),
      evaluatedAt: json['evaluated_at'] != null
          ? DateTime.tryParse(json['evaluated_at'].toString())
          : null,
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
      if (weekLabel != null) 'weekLabel': weekLabel,
      'overallMark': overallMark,
      if (feedback != null) 'feedback': feedback,
    };
  }

  EvaluationModel copyWith({
    String? weekLabel,
    int? overallMark,
    String? feedback,
  }) {
    return EvaluationModel(
      id: id,
      internId: internId,
      mentorId: mentorId,
      weekLabel: weekLabel ?? this.weekLabel,
      overallMark: overallMark ?? this.overallMark,
      feedback: feedback ?? this.feedback,
      evaluatedAt: evaluatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
