/// App 全局配置常量
abstract final class AppConfig {
  /// 应用名称
  static const String appName = '青轻生活';

  /// 当前版本号（与 pubspec.yaml 中 version 字段保持同步）
  static const String appVersionName = '1.0.0';

  /// 当前版本 Code（整数，用于版本比较）
  static const int appVersionCode = 1;

  /// 默认网络超时（秒）
  static const int defaultConnectTimeout = 15;
  static const int defaultReceiveTimeout = 30;

  /// API Base URL（当前为测试环境，正式发布前必须切换为生产地址）
  static const String baseUrl = 'https://apitest.mall.qkj.com.cn';

  /// iOS App Store 应用页地址（如 https://apps.apple.com/cn/app/idxxxxxxxx）
  /// TODO: 上线前填写真实地址；接口文档未提供该字段，为空时 iOS 回退到接口返回的 fileurl。
  static const String appStoreUrl = '';

  /// 微信 AppID（中酒批APP）
  static const String wechatAppId = 'wxeb8af78de10ef6d2';

  /// 微信 iOS Universal Link，需与 apple-app-site-association 及微信开放平台配置一致。
  static const String wechatUniversalLink = 'https://wx.mall.qkj.com.cn/ulink/';

  /// App 内部导航使用的 Deep Link Scheme。
  static const String appScheme = 'qingqinglife';

  /// 商城 H5 通用拉起 App 页面。
  //static const String openAppUrl = 'https://m.mall.qkj.com.cn/mob/common/openapp';
  static const String openAppUrl = 'https://m.mall.qkj.com.cn/mob/common/openapp';
}
