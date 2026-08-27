import 'exceptions/exceptions.dart';

/// 统一 API 响应模型
///
/// T 为业务数据类型，由具体 DataSource 反序列化。
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final bool success;

  const ApiResponse({required this.code, required this.message, this.data, required this.success});

  /// 从后端标准 JSON 构建：{"code":0,"message":"success","data":...}
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    final code = json['code'] as int? ?? -1;
    final message = json['message'] as String? ?? 'unknown error';
    final success = code == 0;
    T? data;
    if (success && fromJsonT != null && json['data'] != null) {
      data = fromJsonT(json['data']);
    }
    return ApiResponse(code: code, message: message, data: data, success: success);
  }

  /// 便捷访问数据，若失败则抛出 ApiException
  T get requireData {
    if (!success) throw ApiException(code: code, message: message);
    if (data == null) throw const ApiException(message: 'data is null');
    return data!;
  }

  /// 成功响应
  factory ApiResponse.success(T data) => ApiResponse<T>(code: 0, message: 'success', data: data, success: true);

  /// 失败响应
  factory ApiResponse.error(String message, {int code = -1}) =>
      ApiResponse<T>(code: code, message: message, data: null, success: false);

  @override
  String toString() => 'ApiResponse(success:$success, code:$code, message:"$message")';
}
