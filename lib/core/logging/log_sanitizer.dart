/// 日志敏感信息脱敏器
///
/// 对密码、Token、手机号、身份证、银行卡、签名等敏感字段进行掩码处理，
/// 防止日志泄露用户隐私或安全凭证。
class LogSanitizer {
  static const List<String> sensitiveFields = [
    'password',
    'passwd',
    'token',
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'authorization',
    'phone',
    'mobile',
    'idCard',
    'id_card',
    'bankCard',
    'bank_card',
    'cardNo',
    'card_no',
    'signature',
  ];

  /// 对单条日志文本进行脱敏
  static String sanitize(String message) {
    var result = message;
    // Bearer Token
    result = result.replaceAll(
        RegExp(r'(Bearer\s+)[A-Za-z0-9._\-]+', caseSensitive: false), '\$1***');
    // 手机号
    result = result.replaceAll(
        RegExp(r'(1[3-9]\d)(\d{4})(\d{4})'), '\$1****\$3');
    // 身份证
    result = result.replaceAll(
        RegExp(r'(\d{6})(\d{8})(\d{4})([0-9Xx])'), '\$1***********\$4');
    return result;
  }

  /// 递归对 Map / List 中的敏感字段脱敏
  static dynamic sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        final keyLower = entry.key.toLowerCase();
        if (sensitiveFields.any((f) => keyLower.contains(f))) {
          result[entry.key] = '[REDACTED]';
        } else {
          result[entry.key] = sanitizeData(entry.value);
        }
      }
      return result;
    }
    if (data is List) {
      return data.map((e) => sanitizeData(e)).toList();
    }
    return data;
  }
}