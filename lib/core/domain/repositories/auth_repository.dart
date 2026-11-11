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
  /// 退出当前会话：调用服务端 /api/sys/logout，并清理本地持久化的 Token 和用户信息
  Future<ApiResponse<void>> logout();

  /// 注销当前账号：调用服务端 /api/sys/deluser，操作不可逆，成功后清理本地所有数据
  Future<ApiResponse<void>> deleteAccount();

  /// 获取当前已登录用户的详细资料
  Future<ApiResponse<UserInfo>> getCurrentUser();

  /// 使用 RefreshToken 刷新已过期的 AccessToken，实现无感登录
  Future<ApiResponse<String>> refreshToken();

  /// 检查当前是否存在有效的登录状态（通常基于 Token 是否存在）
  Future<bool> isLoggedIn();
}

/// 认证操作后的结果封装对象
class AuthResult {
  /// 服务端 authtoken（整数 ID 转字符串），是唯一的登录凭证。
  /// 由 `SessionNotifier.login` 写入 SecureStorage，不再另存第二份。
  final String accessToken;
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
/// 兼容登录接口返回的扁平字段，以及 getmyprofile 返回的
/// baseprofile / rankinfo 嵌套字段。
class UserInfo {
  final String id; // userrid
  final String nickname; // username
  final String? avatarUrl; // avatar（后端可能返回 [URL](URL) markdown 格式）
  final int points; // paycredit / paycredits
  final int memberLevel; // rankinfo.userrid / rankcredits
  final String? phone; // mobile
  final int expiringPoints;
  final int growthValue;
  final int nextLevelStart;
  final int nextLevelEnd;
  final String levelName;
  final String levelIconUrl; // rankinfo.iconurl
  final DateTime? levelExpireDate;
  final int gender; // 0 未知 / 1 男 / 2 女
  final String genderName; // gendername
  final DateTime? birthday; // birthday
  final String? address; // address（getmyprofile 顶层的地址文本）
  final int tianyoudeValue; // baseprofile.apprankcredit（天佑德值/等级积分）

  const UserInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.points = 0,
    this.memberLevel = 1,
    this.phone,
    this.expiringPoints = 0,
    this.growthValue = 0,
    this.nextLevelStart = 0,
    this.nextLevelEnd = 0,
    this.levelName = '',
    this.levelIconUrl = '',
    this.levelExpireDate,
    this.gender = 0,
    this.genderName = '',
    this.birthday,
    this.address,
    this.tianyoudeValue = 0,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final baseProfile = _map(json['baseprofile']);
    final rankInfo = _map(json['rankinfo']);
    final source = baseProfile.isNotEmpty || rankInfo.isNotEmpty ? baseProfile : json;
    final rankSource = rankInfo.isNotEmpty ? rankInfo : json;
    // address 位于 getmyprofile 响应顶层，baseprofile 内没有该字段
    final address = _string(json['address'] ?? source['address']).trim();

    return UserInfo(
      id: _string(source['userrid'] ?? json['userrid']),
      nickname: _string(source['nickname'] ?? source['username']),
      avatarUrl: _cleanAvatarUrl(source['avatar'] as String?),
      points: _int(source['paycredit'] ?? source['paycredits']),
      memberLevel: _int(rankSource['userrid'] ?? json['rankcredits'], fallback: 1),
      phone: source['mobile'] as String?,
      expiringPoints: _int(source['aboutexpirecredit']),
      growthValue: _int(rankSource['currentrankstart']),
      nextLevelStart: _int(rankSource['nextrankstart']),
      nextLevelEnd: _int(rankSource['nextrankend']),
      levelName: _string(rankSource['userridname'] ?? rankSource['nextrankname']),
      levelIconUrl: _string(rankSource['iconurl'] ?? json['iconurl']).trim(),
      levelExpireDate: _dateTime(rankSource['expiredate']),
      gender: _int(source['gender']),
      genderName: _string(source['gendername']),
      birthday: _dateTime(source['birthday']),
      address: address.isEmpty ? null : address,
      tianyoudeValue: _int(source['apprankcredit']),
    );
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  /// 清理 avatar 字段：后端可能返回 [https://...](https://...) 格式的 markdown 链接
  static String? _cleanAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'\[(https?://[^\]]+)\]\(\1\)').firstMatch(url);
    if (match != null) return match.group(1);
    return url.startsWith('http') ? url : null;
  }
}
