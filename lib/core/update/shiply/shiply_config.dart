/// Shiply（原 Bugly 热更新）配置常量
///
/// TODO: 替换为从 Shiply 控制台申请的真实 AppId
abstract final class ShiplyConfig {
  /// Android AppId（占位符，需替换）
  static const String androidAppId = 'YOUR_SHIPLY_ANDROID_APP_ID';

  /// iOS AppId（占位符，需替换）
  static const String iosAppId = 'YOUR_SHIPLY_IOS_APP_ID';

  /// 是否启用 Shiply（开发环境可关闭用于调试）
  static const bool enabled = true;
}
