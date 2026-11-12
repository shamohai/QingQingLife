/// 网络层异常类型
base class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';

  /// 将异常转换为用户可读的提示信息。
  ///
  /// [message] 为空或 "unknown error" 时返回 [fallback]；
  /// 否则返回清洗后的 [message]（去除首尾空白和 \r\n）。
  String toDisplayMessage({String fallback = '操作失败，请稍后重试'}) {
    final trimmed = _cleanMessage(message);
    if (trimmed.isEmpty || trimmed == 'unknown error') return fallback;
    return trimmed;
  }
}

/// 清洗后端返回的 message，去除尾部 \r\n 和首尾空白
String _cleanMessage(String raw) => raw.replaceAll('\r\n', '').replaceAll('\n', '').trim();

/// 供 ApiResponse 和 NetworkException 共用的消息清洗工具
extension MessageCleaning on String {
  /// 去除 \r\n 和首尾空白
  String get cleaned => replaceAll('\r\n', '').replaceAll('\n', '').trim();
}

/// 判断 message 是否为后端默认占位符（视为无有效信息）
bool isDefaultError(String message) {
  final cleaned = message.cleaned;
  return cleaned.isEmpty || cleaned == 'unknown error';
}

/// 将后端原始 message 转为可展示文案：空或占位符时返回 [fallback]，否则返回去除首尾空白后的文本。
///
/// 供 Provider 层统一替代各自的 `_friendlyMessage` 私有实现。
String friendlyMessageOr(String? raw, String fallback) {
  final message = raw?.trim() ?? '';
  return message.isEmpty || message == 'unknown error' ? fallback : message;
}

/// HTTP 状态异常（4xx/5xx）
base class HttpException extends NetworkException {
  const HttpException({required super.message, super.statusCode});
}

/// 网络连接异常
base class ConnectionException extends NetworkException {
  const ConnectionException({required super.message});
}

/// Token 失效异常（由 AuthInterceptor 抛出）
base class AuthException extends NetworkException {
  const AuthException({required super.message});
}

/// 业务逻辑异常（API 返回业务错误码）
///
/// 当后端返回 `result != 0` 且携带 `descr` 时，由 [ApiResponse.requireData] 抛出。
/// [message] 已经过清洗（\r\n / 空白已去除）；[code] 为后端原始错误码。
base class ApiException extends NetworkException {
  final int? code;
  const ApiException({required super.message, this.code, super.statusCode = 200});
}

/// JSON 解析异常
base class ParsingException extends NetworkException {
  const ParsingException({required super.message});
}
