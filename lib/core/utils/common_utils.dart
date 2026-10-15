import 'dart:convert';

/// 通用工具类，存放全项目通用的辅助方法（如安全 JSON 编码、常用格式化等）。
class CommonUtils {
  const CommonUtils._();

  /// 安全将对象转为格式化的 JSON 字符串（防止不可序列化对象崩溃）
  static String safeEncode(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
