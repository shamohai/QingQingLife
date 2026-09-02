import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/api_security_constants.dart';
import '../../crypto/crypto_helper.dart';
import '../../crypto/signature_helper.dart';
import '../../storage/device_storage.dart';

/// 请求加密与签名拦截器
///
/// 对齐 JS 版 `buildPayload` + `baseOptions` 的签名逻辑：
///
/// 请求流程：
/// 1. 收集 meta 信息（设备 ID、平台、版本、渠道等）
/// 2. 从 options.extra['authtoken'] 读取登录 token（由 AuthInterceptor 注入）
/// 3. 构建完整请求体（含 authtoken + meta）
/// 4. AES-CBC 加密请求体
/// 5. 生成 MD5 签名：MD5(加密体 + key + secret)
/// 6. 将签名字段附加到 URL query params：?v=1&key=xxx&sign=xxx&aes=1
/// 7. 发送加密后的 base64 字符串作为请求体
///
/// 响应流程：
/// - 检测响应是否为加密格式（server 返回 aes=1 标记时解密）
/// - 否则按普通 JSON 解析
class EncryptInterceptor extends Interceptor {
  /// 请求体中 authtoken 为 0 时的占位值
  static const String _noAuthToken = '0';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 1. 读取 token（由 AuthInterceptor 预先写入 extra）
      final rawToken = options.extra['authtoken'] as String?;
      final authtoken = (rawToken != null && rawToken.isNotEmpty) ? rawToken : _noAuthToken;

      // 2. 收集设备信息
      final deviceId = await DeviceStorage.getDeviceId();
      final platform = _getFlutterPlatform();
      final os = _getOsNumber(platform);
      final phoneModel = _getPhoneModel();
      final version = await _getAppVersion();
      final channel = ApiSecurityConstants.defaultChannel;

      // 3. 构建明文请求体（JSON）
      final bodyMap = <String, dynamic>{
        'authtoken': int.tryParse(authtoken) ?? 0,
        'meta': {'channel': channel, 'devid': deviceId, 'os': os, 'phonemodel': phoneModel, 'platform': platform, 'version': version},
      };

      // 如果有原始 data，合并进去
      if (options.data != null && options.data is Map) {
        bodyMap.addAll(options.data as Map<String, dynamic>);
      }

      final plainBody = const JsonEncoder.withIndent('  ').convert(bodyMap);

      // 4. AES 加密
      final encryptedBody = CryptoHelper.encrypt(plainBody);

      // 5. 签名
      final key = SignatureHelper.generateKey();
      final sign = SignatureHelper.computeSign(encryptedBody, key);

      // 6. 拼接 URL 参数（Dio 5.x：uri 是 final，通过 copyWith 或直接修改 path/queryParameters）
      final uri = options.uri.replace(
        queryParameters: <String, String>{...options.uri.queryParameters, 'v': '${ApiSecurityConstants.apiVersion}', 'key': key, 'sign': sign, 'aes': '1'},
      );

      options.path = uri.path;
      options.queryParameters = uri.queryParameters;
      options.data = encryptedBody;
      options.headers['Content-Type'] = 'application/octet-stream';
      options.headers['Accept'] = 'application/json';

      if (kDebugMode) {
        debugPrint('[EncryptInterceptor] 加密请求 → ${options.method} ${uri.path}');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[EncryptInterceptor] 拦截器异常: $e\n$st');
      }
      // 拦截器异常不阻断请求，继续发送原始数据
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 服务端可能返回加密响应（当 aes=1 时），尝试解密
    final queryAes = response.requestOptions.uri.queryParameters['aes'];
    if (queryAes == '1' && response.data is String) {
      try {
        final decrypted = CryptoHelper.decrypt(response.data as String);
        response.data = jsonDecode(decrypted) as Map<String, dynamic>?;
        if (kDebugMode) {
          debugPrint('[EncryptInterceptor] 解密响应成功');
        }
      } catch (e) {
        // 解密失败，保留原始响应
        if (kDebugMode) {
          debugPrint('[EncryptInterceptor] 解密响应失败，使用原始响应: $e');
        }
      }
    }
    return handler.next(response);
  }

  /// 获取 Flutter 运行平台（0=app, 1=小程序, 2=web）
  static int _getFlutterPlatform() {
    if (kIsWeb) return 2;
    return 0;
  }

  /// 获取 OS 类型（0=iOS, 1=安卓/鸿蒙）
  static int _getOsNumber(int platform) {
    return Platform.isIOS ? 0 : 1;
  }

  /// 获取手机型号
  static String _getPhoneModel() {
    try {
      if (Platform.isAndroid) {
        return Platform.operatingSystemVersion;
      } else if (Platform.isIOS) {
        return 'iPhone';
      }
    } catch (_) {}
    return 'Unknown';
  }

  /// 获取 App 版本号
  static Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;
    return buildNumber;
  }
}
