import '../../../../core/network/api_response.dart';
import '../../data/models/member_sign_in_models.dart';

/// 会员签到仓库接口
///
/// TODO(Mock): 会员签到后端接口尚未提供，当前由 MockMemberSignInDataSource 实现；
/// 接口就绪后提供 Remote 实现，并在 repository_providers 中替换注册。
abstract class MemberSignInRepository {
  /// 获取签到页总览（我的积分 / 连续签到天数 / 签到日历 / 奖励节点 / 签到明细）
  Future<ApiResponse<MemberSignInOverview>> getSignInOverview();

  /// 执行签到
  Future<ApiResponse<MemberSignInResult>> signIn();
}
