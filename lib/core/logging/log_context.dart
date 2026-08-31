import 'package:uuid/uuid.dart';
import '../../app/config/app_config.dart';

/// 日志上下文，贯穿一次完整业务链路
///
/// 包含 traceId、sessionId、用户信息、设备信息等，
/// 用于将分散在不同模块的日志串成一条可追踪的线索。
class LogContext {
  final String traceId;
  final String sessionId;
  final String? userId;
  final String? deviceId;
  final String appVersion;
  final String? buildNumber;
  final String platform;
  final String? osVersion;
  final String? screen;

  const LogContext({
    required this.traceId,
    required this.sessionId,
    this.userId,
    this.deviceId,
    required this.appVersion,
    this.buildNumber,
    required this.platform,
    this.osVersion,
    this.screen,
  });

  factory LogContext.newTrace({LogContext? parent}) {
    return LogContext(
      traceId: parent?.traceId ?? _nextTraceId(),
      sessionId: parent?.sessionId ?? _sessionId,
      userId: parent?.userId,
      deviceId: parent?.deviceId,
      appVersion: parent?.appVersion ?? AppConfig.appVersionName,
      buildNumber: parent?.buildNumber ?? AppConfig.appVersionCode.toString(),
      platform: parent?.platform ?? _platform,
      osVersion: parent?.osVersion,
      screen: parent?.screen,
    );
  }

  LogContext copyWith({
    String? traceId,
    String? sessionId,
    String? userId,
    String? deviceId,
    String? appVersion,
    String? buildNumber,
    String? platform,
    String? osVersion,
    String? screen,
  }) => LogContext(
        traceId: traceId ?? this.traceId,
        sessionId: sessionId ?? this.sessionId,
        userId: userId ?? this.userId,
        deviceId: deviceId ?? this.deviceId,
        appVersion: appVersion ?? this.appVersion,
        buildNumber: buildNumber ?? this.buildNumber,
        platform: platform ?? this.platform,
        osVersion: osVersion ?? this.osVersion,
        screen: screen ?? this.screen,
      );

  Map<String, dynamic> toJson() => {
        'traceId': traceId,
        'sessionId': sessionId,
        'userId': userId,
        'deviceId': deviceId,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'platform': platform,
        'osVersion': osVersion,
        'screen': screen,
      };

  /// 退出登录时清理用户相关上下文
  LogContext clearUserData() => copyWith(userId: null, deviceId: null);

  static final String _sessionId = const Uuid().v4();
  static String _nextTraceId() => const Uuid().v4();
  static final String _platform = _detectPlatform();

  static String _detectPlatform() {
    // TODO: 接入 device_info_plus 获取真实平台
    return 'unknown';
  }
}