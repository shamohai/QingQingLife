/// App 相关常量（路由名、本地存储 key 等）
abstract final class AppConstants {
  // 本地存储 Key
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeModeKey = 'theme_mode';

  // 分页默认值
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
