String _textOf(dynamic value) => value == null ? '' : value.toString();

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = _textOf(value).toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return int.tryParse(_textOf(value)) ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(_textOf(value)) ?? 0;
}

DateTime? _asDateTime(dynamic value) {
  final text = _textOf(value);
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

class ReferenceUserModel {
  final String id;
  final String fullName;
  final String email;
  final String userRole;

  const ReferenceUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userRole,
  });

  factory ReferenceUserModel.fromJson(dynamic json) {
    final data = _asMap(json);
    return ReferenceUserModel(
      id: _textOf(data['_id'] ?? data['id']),
      fullName: _textOf(data['full_name'] ?? data['name']),
      email: _textOf(data['email']),
      userRole: _textOf(data['user_role']),
    );
  }

  ReferenceUserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? userRole,
  }) {
    return ReferenceUserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
    );
  }
}

class DepartmentReferenceModel {
  final String id;
  final String name;
  final String code;

  const DepartmentReferenceModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory DepartmentReferenceModel.fromJson(dynamic json) {
    final data = _asMap(json);
    return DepartmentReferenceModel(
      id: _textOf(data['_id'] ?? data['id']),
      name: _textOf(data['name']),
      code: _textOf(data['code']),
    );
  }

  DepartmentReferenceModel copyWith({
    String? id,
    String? name,
    String? code,
  }) {
    return DepartmentReferenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }
}

class InternProfileModel {
  final String id;
  final String fullName;
  final String? email;
  final String userRole;
  final DepartmentReferenceModel? department;
  final String? departmentId;
  final String? mentorId;
  final String? accountStatus;
  final bool? isEmailVerified;
  final String? universityId;
  final bool? isValidatedByAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? idPhotoUrl;
  final int? workId;

  const InternProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userRole,
    required this.department,
    required this.departmentId,
    required this.mentorId,
    required this.accountStatus,
    required this.isEmailVerified,
    required this.universityId,
    required this.isValidatedByAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.idPhotoUrl,
    required this.workId,
  });

  factory InternProfileModel.fromJson(dynamic json) {
    final data = _asMap(json);
    final departmentValue = data['department'] ?? data['department_id'];
    final mentorValue = data['mentor_id'];
    final accountStatusValue = _textOf(data['account_status']);
    final departmentIdValue = departmentValue == null
        ? ''
        : _textOf(departmentValue is Map<String, dynamic>
            ? departmentValue['_id'] ?? departmentValue['id']
            : departmentValue);
    final mentorIdValue = mentorValue == null
        ? ''
        : _textOf(mentorValue is Map<String, dynamic>
            ? mentorValue['_id'] ?? mentorValue['id']
            : mentorValue);
    final universityIdValue = _textOf(data['university_id']);
    return InternProfileModel(
      id: _textOf(data['_id'] ?? data['id']),
      fullName: _textOf(data['full_name'] ?? data['name']),
      email: _textOf(data['email']).isEmpty ? null : _textOf(data['email']),
      userRole: _textOf(data['user_role']),
      department: departmentValue == null || departmentValue is String
          ? null
          : DepartmentReferenceModel.fromJson(departmentValue),
      departmentId: departmentIdValue.isEmpty ? null : departmentIdValue,
      mentorId: mentorIdValue.isEmpty ? null : mentorIdValue,
      accountStatus: accountStatusValue.isEmpty ? null : accountStatusValue,
      isEmailVerified: data.containsKey('is_email_verified') ? _asBool(data['is_email_verified']) : null,
      universityId: universityIdValue.isEmpty ? null : universityIdValue,
      isValidatedByAdmin: data.containsKey('is_validated_by_admin') ? _asBool(data['is_validated_by_admin']) : null,
      createdAt: _asDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _asDateTime(data['updated_at'] ?? data['updatedAt']),
      idPhotoUrl: _textOf(data['id_photo_url']).isEmpty ? null : _textOf(data['id_photo_url']),
      workId: data['work_id'] == null ? null : _asInt(data['work_id']),
    );
  }

  InternProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? userRole,
    DepartmentReferenceModel? department,
    String? departmentId,
    String? mentorId,
    String? accountStatus,
    bool? isEmailVerified,
    String? universityId,
    bool? isValidatedByAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? idPhotoUrl,
    int? workId,
  }) {
    return InternProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      mentorId: mentorId ?? this.mentorId,
      accountStatus: accountStatus ?? this.accountStatus,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      universityId: universityId ?? this.universityId,
      isValidatedByAdmin: isValidatedByAdmin ?? this.isValidatedByAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      idPhotoUrl: idPhotoUrl ?? this.idPhotoUrl,
      workId: workId ?? this.workId,
    );
  }
}

class InternAssignmentModel {
  final String id;
  final String internId;
  final String mentorId;
  final String departmentId;
  final ReferenceUserModel? mentor;
  final DepartmentReferenceModel? department;
  final String? assignedByAdminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternAssignmentModel({
    required this.id,
    required this.internId,
    required this.mentorId,
    required this.departmentId,
    required this.mentor,
    required this.department,
    required this.assignedByAdminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternAssignmentModel.fromJson(dynamic json) {
    final data = _asMap(json);
    final mentorValue = data['mentor_id'];
    final departmentValue = data['department_id'];
    return InternAssignmentModel(
      id: _textOf(data['_id'] ?? data['id']),
      internId: _textOf(data['intern_id']),
      mentorId: _textOf(mentorValue is Map<String, dynamic> ? mentorValue['_id'] ?? mentorValue['id'] : mentorValue),
      departmentId: _textOf(departmentValue is Map<String, dynamic> ? departmentValue['_id'] ?? departmentValue['id'] : departmentValue),
      mentor: mentorValue is Map<String, dynamic> ? ReferenceUserModel.fromJson(mentorValue) : null,
      department: departmentValue is Map<String, dynamic> ? DepartmentReferenceModel.fromJson(departmentValue) : null,
      assignedByAdminId: _textOf(data['assigned_by_admin_id']).isEmpty ? null : _textOf(data['assigned_by_admin_id']),
      createdAt: _asDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _asDateTime(data['updated_at'] ?? data['updatedAt']),
    );
  }

  String get mentorName => mentor?.fullName.isNotEmpty == true ? mentor!.fullName : mentorId;
  String get departmentName => department?.name.isNotEmpty == true ? department!.name : departmentId;
}

class InternScheduleModel {
  final String id;
  final String title;
  final DepartmentReferenceModel? department;
  final String internId;
  final ReferenceUserModel? mentor;
  final String weekday;
  final DateTime? scheduleDate;
  final String startTime;
  final String endTime;
  final String? notes;
  final String? uploadedByAdminId;
  final bool isActive;
  final String? fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternScheduleModel({
    required this.id,
    required this.title,
    required this.department,
    required this.internId,
    required this.mentor,
    required this.weekday,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.uploadedByAdminId,
    required this.isActive,
    required this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternScheduleModel.fromJson(dynamic json) {
    final data = _asMap(json);
    final departmentValue = data['department_id'];
    final mentorValue = data['mentor_id'];
    return InternScheduleModel(
      id: _textOf(data['_id'] ?? data['id']),
      title: _textOf(data['title']),
      department: departmentValue is Map<String, dynamic> ? DepartmentReferenceModel.fromJson(departmentValue) : null,
      internId: _textOf(data['intern_id']),
      mentor: mentorValue is Map<String, dynamic> ? ReferenceUserModel.fromJson(mentorValue) : null,
      weekday: _textOf(data['weekday']),
      scheduleDate: _asDateTime(data['schedule_date'] ?? data['scheduleDate']),
      startTime: _textOf(data['start_time'] ?? data['startTime']),
      endTime: _textOf(data['end_time'] ?? data['endTime']),
      notes: _textOf(data['notes']).isEmpty ? null : _textOf(data['notes']),
      uploadedByAdminId: _textOf(data['uploaded_by_admin_id']).isEmpty ? null : _textOf(data['uploaded_by_admin_id']),
      isActive: _asBool(data['is_active']),
      fileUrl: _textOf(data['file_url'] ?? data['url'] ?? data['file']).isEmpty
          ? null
          : _textOf(data['file_url'] ?? data['url'] ?? data['file']),
      createdAt: _asDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _asDateTime(data['updated_at'] ?? data['updatedAt']),
    );
  }

  String get mentorName => mentor?.fullName.isNotEmpty == true ? mentor!.fullName : 'Mentor';
  String get departmentName => department?.name.isNotEmpty == true ? department!.name : 'Department';
  String get timeRange => startTime.isEmpty && endTime.isEmpty ? 'TBA' : '$startTime - $endTime';
}

class InternTrainingModuleModel {
  final String id;
  final String title;
  final String? description;
  final String departmentId;
  final String departmentCode;
  final String targetRole;
  final String fileUrl;
  final String? uploadedByAdminId;
  final int version;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternTrainingModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    required this.departmentCode,
    required this.targetRole,
    required this.fileUrl,
    required this.uploadedByAdminId,
    required this.version,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternTrainingModuleModel.fromJson(dynamic json) {
    final data = _asMap(json);
    return InternTrainingModuleModel(
      id: _textOf(data['_id'] ?? data['id']),
      title: _textOf(data['title']),
      description: _textOf(data['description']).isEmpty ? null : _textOf(data['description']),
      departmentId: _textOf(data['department_id']),
      departmentCode: _textOf(data['department_code']),
      targetRole: _textOf(data['target_role']),
      fileUrl: _textOf(data['file_url'] ?? data['url']),
      uploadedByAdminId: _textOf(data['uploaded_by_admin_id']).isEmpty ? null : _textOf(data['uploaded_by_admin_id']),
      version: _asInt(data['version']),
      isActive: _asBool(data['is_active']),
      createdAt: _asDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _asDateTime(data['updated_at'] ?? data['updatedAt']),
    );
  }
}

class InternWorkCardModel {
  final int? workId;
  final String? idPhotoUrl;
  final InternProfileModel profile;

  const InternWorkCardModel({
    required this.workId,
    required this.idPhotoUrl,
    required this.profile,
  });

  factory InternWorkCardModel.fromJson(dynamic json) {
    final data = _asMap(json);
    final workIdCard = _asMap(data['work_id_card']);
    final internProfile = _asMap(data['intern_profile']);
    final mergedProfile = <String, dynamic>{
      ...internProfile,
    };
    if (workIdCard['work_id'] != null) {
      mergedProfile['work_id'] = workIdCard['work_id'];
    }
    if (workIdCard['id_photo_url'] != null) {
      mergedProfile['id_photo_url'] = workIdCard['id_photo_url'];
    }
    final profile = InternProfileModel.fromJson(mergedProfile);

    return InternWorkCardModel(
      workId: profile.workId,
      idPhotoUrl: profile.idPhotoUrl,
      profile: profile,
    );
  }

  InternWorkCardModel copyWith({
    int? workId,
    String? idPhotoUrl,
    InternProfileModel? profile,
  }) {
    return InternWorkCardModel(
      workId: workId ?? this.workId,
      idPhotoUrl: idPhotoUrl ?? this.idPhotoUrl,
      profile: profile ?? this.profile,
    );
  }
}

class InternEvaluationModel {
  final String id;
  final String internId;
  final String mentorId;
  final ReferenceUserModel? mentor;
  final String weekLabel;
  final double overallMark;
  final String? feedback;
  final DateTime? evaluatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternEvaluationModel({
    required this.id,
    required this.internId,
    required this.mentorId,
    required this.mentor,
    required this.weekLabel,
    required this.overallMark,
    required this.feedback,
    required this.evaluatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternEvaluationModel.fromJson(dynamic json) {
    final data = _asMap(json);
    final mentorValue = data['mentor_id'];
    return InternEvaluationModel(
      id: _textOf(data['_id'] ?? data['id']),
      internId: _textOf(data['intern_id']),
      mentorId: _textOf(mentorValue is Map<String, dynamic> ? mentorValue['_id'] ?? mentorValue['id'] : mentorValue),
      mentor: mentorValue is Map<String, dynamic> ? ReferenceUserModel.fromJson(mentorValue) : null,
      weekLabel: _textOf(data['week_label'] ?? data['weekLabel']),
      overallMark: _asDouble(data['overall_mark'] ?? data['overallMark']),
      feedback: _textOf(data['feedback']).isEmpty ? null : _textOf(data['feedback']),
      evaluatedAt: _asDateTime(data['evaluated_at'] ?? data['evaluatedAt']),
      createdAt: _asDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _asDateTime(data['updated_at'] ?? data['updatedAt']),
    );
  }

  String get mentorName => mentor?.fullName.isNotEmpty == true ? mentor!.fullName : mentorId;
}