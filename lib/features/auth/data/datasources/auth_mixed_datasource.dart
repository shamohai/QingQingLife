import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/network/api_response.dart';
import 'auth_mock_datasource.dart';
import 'auth_remote_datasource.dart';

/// 过渡期混合认证数据源
///
/// 后端能力尚未全部就绪，按方法拆分数据源：
///   - 微信授权登录（loginWithWeChat / loginWithWeChatCode）：后端已就绪并测试通过，走真实接口。
///   - 绑定手机号（sendSmsCode + phoneBind）：后端仍在开发，走 Mock 数据。
///   - 其余认证能力：走真实接口。
///
/// 待 bindPhone / sendCode 后端就绪后，删除本类，
/// `authRepository` 直接返回 `remoteAuthDataSourceProvider` 即可。
class AuthMixedDataSource implements AuthRepository {
  final RemoteAuthDataSource remote;
  final MockAuthDataSource mock;

  AuthMixedDataSource({required this.remote, required this.mock});

  // ── 微信授权登录：真实接口 ───────────────────────────────
  @override
  Future<ApiResponse<AuthResult>> loginWithWeChat() => remote.loginWithWeChat();

  @override
  Future<ApiResponse<AuthResult>> loginWithWeChatCode({required String code}) => remote.loginWithWeChatCode(code: code);

  // ── 绑定手机号：Mock（后端开发中）────────────────────────
  @override
  Future<ApiResponse<AuthResult>> phoneBind({required String phone, required String code, required String wechatCode}) =>
      mock.phoneBind(phone: phone, code: code, wechatCode: wechatCode);

  @override
  Future<ApiResponse<void>> sendSmsCode({required String phone}) => mock.sendSmsCode(phone: phone);

  // ── 其余认证能力：真实接口 ───────────────────────────────
  @override
  Future<ApiResponse<AuthResult>> loginWithPhone({required String phone, required String code}) => remote.loginWithPhone(phone: phone, code: code);

  @override
  Future<void> logout() => remote.logout();

  @override
  Future<ApiResponse<UserInfo>> getCurrentUser() => remote.getCurrentUser();

  @override
  Future<ApiResponse<String>> refreshToken() => remote.refreshToken();

  @override
  Future<bool> isLoggedIn() => remote.isLoggedIn();
}
