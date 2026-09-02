import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../constants/api_security_constants.dart';

/// 请求签名工具
///
/// 对齐 JS 版逻辑：
///   sign = MD5(encryptedBody + key + secret)
/// key = timestamp + uuid
class SignatureHelper {
  SignatureHelper._();

  /// 生成本次请求的唯一 key
  /// 格式：毫秒时间戳 + uuid_v4
  static String generateKey() {
    return '${DateTime.now().millisecondsSinceEpoch}${const Uuid().v4()}';
  }

  /// 计算 MD5 签名
  /// [body] 加密后的 body 字符串（base64）
  static String computeSign(String body, String key) {
    final bytes = utf8.encode(body + key + ApiSecurityConstants.signSecret);
    return md5.convert(bytes).toString();
  }
}
