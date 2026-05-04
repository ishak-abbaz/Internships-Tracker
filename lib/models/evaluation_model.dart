class EvaluationModel {
  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final String? weekLabel;
  final int overallMark;
  final String? feedback;
  final DateTime evaluatedAt;

  EvaluationModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    this.weekLabel,
    required this.overallMark,
    this.feedback,
    required this.evaluatedAt,
  });

  DateTime get createdAt => evaluatedAt;

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    String? mName;
    final mentorData = json['mentor_id'];
    if (mentorData is Map) {
      mName = mentorData['full_name'] ?? mentorData['name'];
    }

    String? iName;
    final internData = json['intern_id'];
    if (internData is Map) {
      iName = internData['full_name'] ?? internData['name'];
    }

    return EvaluationModel(
      id: json['_id'] ?? '',
      internId: json['intern_id'] is Map ? json['intern_id']['_id'] : (json['intern_id'] ?? ''),
      internName: iName,
      mentorId: json['mentor_id'] is Map ? json['mentor_id']['_id'] : (json['mentor_id'] ?? ''),
      mentorName: mName,
      weekLabel: json['week_label'],
      overallMark: (json['overall_mark'] ?? 0).toInt(),
      feedback: json['feedback'],
      evaluatedAt: json['evaluated_at'] != null 
          ? DateTime.parse(json['evaluated_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intern_id': internId,
      'mentor_id': mentorId,
      'week_label': weekLabel,
      'overall_mark': overallMark,
      'feedback': feedback,
      'evaluated_at': evaluatedAt.toIso8601String(),
    };
  }
}
