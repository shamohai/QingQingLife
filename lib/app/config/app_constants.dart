/// App 相关常量（路由名、本地存储 key 等）
abstract final class AppConstants {
  // 本地存储 Key
  //
  // 用户令牌只保存一份：服务端 authtoken 即登录凭证，
  // 不要再用第二套 Key 保存同一个值，否则两处会各自过期、难以判断真实登录态。
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String deviceIdKey = 'auth_device_id';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeModeKey = 'theme_mode';

  // 热更新相关存储 Key
  static const String lastSuggestUpdateTsKey = 'last_suggest_update_ts';
  static const String resourceManifestVersionKey = 'resource_manifest_version';
  static const String resourceLastCheckTsKey = 'resource_last_check_ts';

  // 分页默认值
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
