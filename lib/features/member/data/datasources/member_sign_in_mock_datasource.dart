import '../../../../core/network/api_response.dart';
import '../../domain/repositories/member_sign_in_repository.dart';
import '../models/member_sign_in_models.dart';

/// Mock 会员签到数据源 - 开发/测试环境使用
///
/// TODO(Mock): 会员签到后端接口尚未提供，当前返回本地 Mock 数据；
/// 数值对齐设计稿：我的积分 143,544、连续签到 3 天、今日（10月4日）已签到、
/// 日历 10月1日~10月7日（第 7 天奖励 20 积分）、连续签到奖励节点（第1/3/7天）。
/// 接口就绪后，由 Remote 数据源替换（替换注册见 repository_providers）。
class MockMemberSignInDataSource implements MemberSignInRepository {
  /// 我的积分（与积分商城 Mock 保持一致：143,544）
  static const int points = 143544;

  /// 已连续签到天数（设计稿：3 天）
  static const int consecutiveDays = 3;

  @override
  Future<ApiResponse<MemberSignInOverview>> getSignInOverview() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      const MemberSignInOverview(
        points: points,
        consecutiveDays: consecutiveDays,
        days: [
          MemberSignInDay(label: '10月1日', points: 2, state: MemberSignInDayState.signed),
          MemberSignInDay(label: '10月2日', points: 2, state: MemberSignInDayState.signed),
          MemberSignInDay(label: '10月3日', points: 2, state: MemberSignInDayState.signed),
          MemberSignInDay(label: '10月4日', points: 2, state: MemberSignInDayState.today),
          MemberSignInDay(label: '10月5日', points: 2, state: MemberSignInDayState.upcoming),
          MemberSignInDay(label: '10月6日', points: 2, state: MemberSignInDayState.upcoming),
          MemberSignInDay(label: '10月7日', points: 20, state: MemberSignInDayState.upcoming),
        ],
        milestones: [
          MemberSignInMilestone(label: '第1天', rewardPoints: 10, reached: true, connectorProgress: 1.0),
          MemberSignInMilestone(label: '第3天', rewardPoints: 10, reached: true, connectorProgress: 0.45),
          MemberSignInMilestone(label: '第7天', rewardPoints: 10, reached: false, connectorProgress: 0.0),
        ],
        records: [
          MemberSignInRecord(date: '2026年10月4日', subtitle: '日常签到', points: 2),
          MemberSignInRecord(date: '2026年10月3日', subtitle: '连续签到奖励', points: 10),
          MemberSignInRecord(date: '2026年10月3日', subtitle: '日常签到', points: 2),
          MemberSignInRecord(date: '2026年10月2日', subtitle: '日常签到', points: 2),
          MemberSignInRecord(date: '2026年10月1日', subtitle: '日常签到', points: 2),
        ],
        signedToday: true,
      ),
    );
  }

  @override
  Future<ApiResponse<MemberSignInResult>> signIn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO(Mock): 设计稿状态为「今日已签到」，真实接口就绪后按后端返回结果处理。
    return ApiResponse.success(const MemberSignInResult(signed: false, pointsEarned: 0, message: '今日已签到'));
  }
}
