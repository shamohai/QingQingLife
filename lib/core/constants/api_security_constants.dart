/// API 安全相关常量
///
/// 对应 JS 版 api.js 中的硬编码值，避免散落在各处。
abstract final class ApiSecurityConstants {
  /// AES-CBC 加密密钥（16字节）
  /// 来源：JS api.js `static encrypt` 中的 key
  static const String aesKey = '1234567812345678';

  /// AES-CBC 初始化向量（16字节）
  /// 来源：JS api.js `static encrypt` 中的 iv
  static const String aesIv = '1234567812345678';

  /// MD5 签名密钥（与后端约定）
  /// 来源：JS api.js sign 计算中的末尾字符串
  static const String signSecret = 'LCSLCSCS';

  /// API 版本号，固定为 1
  static const int apiVersion = 1;

  /// 默认渠道：安卓独立安装包（apk）
  /// 10000000 = iOS；20000000 = 安卓
  static const String defaultChannel = '20000000';

  /// 默认平台：小程序
  /// 0 = app；1 = 小程序；2 = web
  /// 当前 App 为独立 Flutter 应用，但接口文档示例传 1（小程序）
  static const int defaultPlatform = 0;

  /// 设备 ID 持久化存储 Key
  static const String deviceIdStorageKey = 'qingqinglife-device-id';
}
