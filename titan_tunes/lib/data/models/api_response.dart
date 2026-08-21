class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final int? status;
  final String? timestamp;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.status,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) parser,
  ) {
    List<String>? parsedErrors;
    if (json['errors'] is List) {
      parsedErrors = (json['errors'] as List).map((e) => e.toString()).toList();
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? parser(json['data']) : null,
      errors: parsedErrors,
      status: json['status'] as int?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJson) {
    return {
      'success': success,
      'message': message,
      'data': data == null ? null : toJson(data as T),
      'errors': errors,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parser,
  ) {
    final rawContent = json['content'];
    final List<T> list = [];
    if (rawContent is List) {
      for (final item in rawContent) {
        if (item is Map<String, dynamic>) {
          list.add(parser(item));
        } else if (item is Map) {
          list.add(parser(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PageResponse<T>(
      content: list,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: json['totalElements'] as int? ?? list.length,
      totalPages: json['totalPages'] as int? ?? (list.isNotEmpty ? 1 : 0),
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? list.isEmpty,
    );
  }
}
