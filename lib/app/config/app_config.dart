/// App 全局配置常量
abstract final class AppConfig {
  /// 应用名称
  static const String appName = '青轻生活馆';

  /// 默认网络超时（秒）
  static const int defaultConnectTimeout = 15;
  static const int defaultReceiveTimeout = 30;

  /// API Base URL 占位符（待后端对接时替换）
  static const String baseUrl = 'https://api.example.com';

  /// 微信 AppID（需要在微信开放平台申请，此处为占位符）
  /// TODO: 替换为真实的微信 AppID
  static const String wechatAppId = 'wxplaceholder12345678';
}
