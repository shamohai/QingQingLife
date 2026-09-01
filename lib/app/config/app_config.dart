/// App 全局配置常量
abstract final class AppConfig {
  /// 应用名称
  static const String appName = '青轻生活馆';

  /// 当前版本号（与 pubspec.yaml 中 version 字段保持同步）
  static const String appVersionName = '1.0.0';

  /// 当前版本 Code（整数，用于版本比较）
  static const int appVersionCode = 1;

  /// 默认网络超时（秒）
  static const int defaultConnectTimeout = 15;
  static const int defaultReceiveTimeout = 30;

  /// API Base URL 占位符（待后端对接时替换）
  static const String baseUrl = 'https://api.example.com';

  /// 资源 CDN 基础域名（待配置真实 CDN 地址）
  static const String resourceCdnBaseUrl = 'https://cdn.example.com/qingqinglife';

  /// 微信 AppID（中酒批APP）
  static const String wechatAppId = 'wx64999b13fa01a983';
}
