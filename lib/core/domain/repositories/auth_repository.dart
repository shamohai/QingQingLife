import '../../network/api_response.dart';

/// 认证业务仓库接口
///
/// 定义了用户登录、登出、身份核验及个人信息获取的核心协议。
/// 具体实现类（如 AuthRepositoryImpl）应负责与 ApiClient 交互并处理持久化（Token 存储）。
abstract class AuthRepository {
  /// 发起手机号 + 验证码的登录请求
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code});

  /// 微信第三方登录授权请求
  Future<ApiResponse<AuthResult>> loginWithWeChat();

  /// 微信授权登录后传入 code 换取 Token，code 由 fluwx 授权回调获取
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code});

  /// 微信登录后绑定手机号
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode});

  /// 获取指定手机号的短信验证码
  Future<ApiResponse<void>> sendSmsCode({required String phone});

  /// 退出当前会话，清理本地持久化的 Token 和用户信息
  Future<void> logout();

  /// 获取当前已登录用户的详细资料
  Future<ApiResponse<UserInfo>> getCurrentUser();

  /// 使用 RefreshToken 刷新已过期的 AccessToken，实现无感登录
  Future<ApiResponse<String>> refreshToken();

  /// 检查当前是否存在有效的登录状态（通常基于 Token 是否存在）
  Future<bool> isLoggedIn();
}

/// 认证操作后的结果封装对象
class AuthResult {
  final String accessToken; // authtoken（服务端整数 ID），转为字符串存入 SecureStorage
  final String? refreshToken; // 暂不支持，保留字段
  final UserInfo userInfo;

  const AuthResult({required this.accessToken, this.refreshToken, required this.userInfo});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    // 后端返回 authtoken（int），直接取整数字段
    final authToken = json['authtoken'];
    if (authToken == null) {
      throw FormatException('登录响应缺少 authtoken，响应字段: ${json.keys.join(', ')}');
    }
    final accessToken = authToken.toString();
    final userInfo = UserInfo.fromJson(json);
    return AuthResult(accessToken: accessToken, refreshToken: null, userInfo: userInfo);
  }
}

/// 用户领域实体对象
///
/// 对应 /api/sys/app/login 返回的扁平字段。
class UserInfo {
  final String id; // userrid
  final String nickname; // username
  final String? avatarUrl; // avatar（后端可能返回 [URL](URL) markdown 格式）
  final int points; // paycredits
  final int memberLevel; // rankcredits
  final String? phone; // mobile

  const UserInfo({required this.id, required this.nickname, this.avatarUrl, this.points = 0, this.memberLevel = 1, this.phone});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: (json['userrid'] as int?)?.toString() ?? '',
        nickname: (json['username'] as String?) ?? '',
        avatarUrl: _cleanAvatarUrl(json['avatar'] as String?),
        points: json['paycredits'] as int? ?? 0,
        memberLevel: json['rankcredits'] as int? ?? 1,
        phone: json['mobile'] as String?,
      );

  /// 清理 avatar 字段：后端可能返回 [https://...](https://...) 格式的 markdown 链接
  static String? _cleanAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'\[(https?://[^\]]+)\]\(\1\)').firstMatch(url);
    if (match != null) return match.group(1);
    return url.startsWith('http') ? url : null;
  }
}
