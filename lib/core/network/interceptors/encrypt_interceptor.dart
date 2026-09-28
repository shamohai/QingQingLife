import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/api_security_constants.dart';
import '../../crypto/signature_helper.dart';
import '../../storage/device_storage.dart';

import 'dart:js_interop';

import 'package:web/web.dart' show console;

import '../../logging/interceptors/app_logging_interceptor.dart';

/// 请求加密与签名拦截器
///
/// 对齐 JS 版 `buildPayload` + `baseOptions` 的签名逻辑：
///
/// 请求流程：
/// 1. 收集 meta 信息（设备 ID、平台、版本、渠道等）
/// 2. 从 options.extra['authtoken'] 读取登录 token（由 AuthInterceptor 注入）
/// 3. 构建完整请求体（含 authtoken + meta）
/// 5. 生成 MD5 签名：MD5(key + secret)
/// 6. 将签名字段附加到 URL query params：?v=1&key=xxx&sign=xxx
/// 7. 发送加密后的 base64 字符串作为请求体
///
/// 响应流程：
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
        bodyMap.addAll(Map<String, dynamic>.from(options.data as Map));
      }

      final plainBody = const JsonEncoder.withIndent('  ').convert(bodyMap);

      // 5. 签名
      final key = SignatureHelper.generateKey();
      final sign = SignatureHelper.computeSign(plainBody, key);

      // 6. 拼接 URL 参数（Dio 5.x：uri 是 final，通过 copyWith 或直接修改 path/queryParameters）
      final uri = options.uri.replace(
        queryParameters: <String, String>{...options.uri.queryParameters, 'v': '${ApiSecurityConstants.apiVersion}', 'key': key, 'sign': sign},
      );

      options.path = uri.path;
      options.queryParameters = uri.queryParameters;
      options.data = plainBody;
      options.headers['Content-Type'] = 'application/json; charset=utf-8';
      options.headers['Accept'] = 'application/json';

      if (kDebugMode) {
        //debugPrint('[EncryptInterceptor] API请求 → ${options.method} ${uri.path}');
        if (kIsWeb) {
          console.log((options.path + ' 接口Request参数：' + AppLoggingInterceptor.safeEncode(options.data)).toJS);
        }
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
    return handler.next(response);
  }

  /// 获取 Flutter 运行平台（0=app, 1=小程序, 2=web）
  static int _getFlutterPlatform() {
    if (kIsWeb) return 1;
    return 0;
  }

  /// 获取 OS 类型（0=iOS, 1=安卓/鸿蒙）
  static int _getOsNumber(int platform) {
    if (kIsWeb) return 1;
    return Platform.isIOS ? 0 : 1;
  }

  /// 获取手机型号
  static String _getPhoneModel() {
    if (kIsWeb) return 'Web Browser';
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
