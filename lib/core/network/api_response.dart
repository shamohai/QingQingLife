import 'exceptions/exceptions.dart';

/// 统一 API 响应模型
/// 
/// 支持两种后端响应格式：
/// 
/// **格式 A（标准）**：{"code": 0, "message": "success", "data": {...}}
///   - code == 0 表示成功
///   - data 为业务数据
/// 
/// **格式 B（扁平）**：{"result": 0, "descr": null, "uid": 123, ...}
///   - result == 0 表示成功
///   - 其余字段直接作为业务数据返回（无 data 包装层）
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final bool success;

  const ApiResponse({required this.code, required this.message, this.data, required this.success});

  /// 从后端 JSON 构建，自动适配两种响应格式
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    // 优先检查标准格式：code / message
    final intCode = json['code'] as int?;
    final intResult = json['result'] as int?;
    final code = intCode ?? intResult ?? -1;
    final message = (json['message'] as String?) ?? (json['descr'] as String?) ?? 'unknown error';
    final success = code == 0;

    T? data;
    if (success && fromJsonT != null && json['data'] != null) {
      // 格式 A：数据在 data 字段中
      data = fromJsonT(json['data']);
    } else if (success && fromJsonT != null && json.length > 2) {
      // 格式 B：扁平响应，整体作为 data 返回（过滤掉 result/descr/datatag 等状态字段）
      final dataFields = json.entries
          .where((e) => e.key != 'result' && e.key != 'descr' && e.key != 'datatag' && e.key != 'code' && e.key != 'message')
          .fold(<String, dynamic>{}, (map, e) => map..[e.key] = e.value);
      if (dataFields.isNotEmpty) {
        data = fromJsonT(dataFields);
      }
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
