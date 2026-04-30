class CreateInternResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  CreateInternResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateInternResponse.fromJson(Map<String, dynamic> json) {
    return CreateInternResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
