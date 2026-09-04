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
  final String accessToken;  // 短期访问令牌
  final String? refreshToken; // 长期刷新令牌（可选，部分环境可能不支持）
  final UserInfo userInfo;    // 登录成功后的基础用户信息

  const AuthResult({required this.accessToken, this.refreshToken, required this.userInfo});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    userInfo: UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
  );
}

/// 用户领域实体对象
/// 
/// 承载了业务层面的核心用户属性。
class UserInfo {
  final String id;           // 用户唯一标识符
  final String nickname;     // 昵称
  final String? avatarUrl;   // 头像地址
  final int points;          // 当前积分余量
  final int memberLevel;     // 会员等级 (e.g., 1:普通会员, 2:白银...)
  final String? phone;       // 脱敏后的手机号

  const UserInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.points = 0,
    this.memberLevel = 1,
    this.phone,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    points: json['points'] as int? ?? 0,
    memberLevel: json['memberLevel'] as int? ?? 1,
    phone: json['phone'] as String?,
  );
}
