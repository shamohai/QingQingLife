/// 网络层异常类型
base class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
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
base class ApiException extends NetworkException {
  final int? code;
  const ApiException({required super.message, this.code, super.statusCode = 200});
}

/// JSON 解析异常
base class ParsingException extends NetworkException {
  const ParsingException({required super.message});
}