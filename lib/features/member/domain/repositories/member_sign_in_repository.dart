import '../../../../core/network/api_response.dart';
import '../../data/models/member_sign_in_models.dart';

/// 会员签到仓库接口
///
/// 后端签到接口尚未提供，当前由 [MemberDataSource] 返回失败响应；
/// 接口就绪后在数据源中接入真实请求即可，无需修改本接口。
abstract class MemberSignInRepository {
  /// 获取签到页总览（我的积分 / 连续签到天数 / 签到日历 / 奖励节点 / 签到明细）
  Future<ApiResponse<MemberSignInOverview>> getSignInOverview();

  /// 执行签到
  Future<ApiResponse<MemberSignInResult>> signIn();
}
