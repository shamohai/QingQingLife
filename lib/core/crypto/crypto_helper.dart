import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import '../constants/api_security_constants.dart';

/// AES-CBC 加解密工具
/// 
/// 对齐 JS 版 `CryptoJS.AES` 的 ZeroPadding 行为：
/// - 模式：CBC
/// - 填充：ZeroPadding（JS CryptoJS 实现：补零到 block size 的倍数）
/// - 密钥/IV：均为 "1234567812345678"（UTF-8）
/// - 输出/输入：Base64 字符串
class CryptoHelper {
  CryptoHelper._();

  static final _key = enc.Key.fromUtf8(ApiSecurityConstants.aesKey);
  static final _iv = enc.IV.fromUtf8(ApiSecurityConstants.aesIv);
  static final _encrypter = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc, padding: null),
  );

  /// 对明文进行 ZeroPadding（对齐 JS CryptoJS ZeroPadding 行为）
  /// 补零至 16 字节对齐
  static List<int> zeroPad(List<int> input) {
    const blockSize = 16;
    final remainder = input.length % blockSize;
    if (remainder == 0) return input;
    final paddingBytes = blockSize - remainder;
    final result = Uint8List(input.length + paddingBytes);
    result.setRange(0, input.length, input);
    return result.toList();
  }

  /// 加密：明文 → Base64 密文
  /// 
  /// 使用 UTF-8 字节编码（对齐 JS CryptoJS 行为），而非 UTF-16 codeUnits。
  static String encrypt(String plainText) {
    final plainBytes = utf8.encode(plainText);
    final paddedBytes = zeroPad(plainBytes);
    final encrypted = _encrypter.encryptBytes(Uint8List.fromList(paddedBytes), iv: _iv);
    return encrypted.base64;
  }

  /// 解密：Base64 密文 → 明文
  /// 
  /// 解密后剥离末尾的零填充字节（对齐 JS CryptoJS ZeroPadding 行为）
  static String decrypt(String base64CipherText) {
    final decrypted = _encrypter.decryptBytes(
      enc.Encrypted.fromBase64(base64CipherText),
      iv: _iv,
    );
    // 剥离末尾零填充
    int end = decrypted.length;
    while (end > 0 && decrypted[end - 1] == 0) {
      end--;
    }
    return utf8.decode(decrypted.sublist(0, end));
  }

  /// 打印调试信息（仅 debug 模式）
  static void logDebug(String label, dynamic value) {
    if (kDebugMode) {
      debugPrint('[CryptoHelper] $label: $value');
    }
  }
}
