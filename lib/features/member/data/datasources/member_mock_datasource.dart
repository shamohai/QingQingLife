import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/member_repository.dart';
import '../../../../core/network/api_response.dart';

/// Mock 会员数据源 - 开发/测试环境使用
class MockMemberDataSource implements MemberRepository {
  @override
  Future<ApiResponse<MemberInfo>> getMemberInfo() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ApiResponse.success(
      const MemberInfo(
        id: 'u001',
        nickname: '青轻用户_9527',
        memberLevel: 2,
        levelName: '银卡会员',
        growthValue: 1250,
        nextLevelGrowthValue: 2000,
        points: 3580,
        availableCoupons: 5,
        hasHousekeeper: false,
      ),
    );
  }

  @override
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(MemberLevelBenefits(level: level, name: level == 2 ? '银卡会员' : '会员', benefits: ['专享价', '免运费', '积分加速']));
  }

  @override
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ApiResponse.success(
      CouponListResult(
        coupons: [
          Coupon(
            id: 'c1',
            templateId: 't1',
            name: '新人专享券',
            description: '满100减20',
            type: CouponType.discount,
            discountCents: 2000,
            minOrderCents: 10000,
            startTime: DateTime.now().subtract(const Duration(days: 30)),
            endTime: DateTime.now().add(const Duration(days: 30)),
            status: CouponStatus.available,
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 10,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ApiResponse<void>> claimCoupon(String couponTemplateId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<PointsAccount>> getPointsAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      const PointsAccount(totalPoints: 3580, availablePoints: 3580, frozenPoints: 0, expiringPoints: 800, todayEarned: 10, totalEarned: 3580),
    );
  }

  @override
  Future<ApiResponse<PointsLogResult>> getPointsLogs({required int page, required int pageSize, PointsLogType? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      PointsLogResult(
        logs: [PointsLog(id: 'log1', type: PointsLogType.earn, points: 10, balanceAfter: 3580, description: '每日签到', createTime: DateTime.now())],
        total: 1,
        page: 1,
        pageSize: 10,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ApiResponse<String>> getPointsRules() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(
      '为规范青轻生活馆APP（以下简称“本APP”）积分商城运营，保障全体用户合法权益，明确积分获取、使用、兑换、失效等相关规则，营造公平、有序的平台消费体验，特制定本积分规则。本规则适用于所有注册并使用本APP积分商城功能的用户，开通积分功能即视为自愿认可并遵守本规则全部条款。 一、积分基本定义 1. 青轻积分是本APP专属虚拟权益，仅可在青轻生活馆APP积分商城内使用，为用户专属消费兑换凭证，不支持提现、转账、售卖、折现、透支，不可兑换现金、不找零、不开发票，仅限本人账户使用，严禁跨账户转移、合并积分。 2. 积分分为累积积分与可用积分：累积积分是用户历史累计获得的全部积分总和，可作为用户平台活跃度、会员等级评定依据；可用积分是扣除已兑换、冻结、失效积分后，可正常用于商城兑换、权益抵扣的有效积分，日常消费兑换仅扣除可用积分。 二、积分获取规则 （一）新手专属积分 2. 新手完善资料：新用户完成头像、昵称、收货地址等基础资料完善，额外领取50积分，一次性领取。 1. 每日签到：用户每日登录APP完成签到，可领取5-15随机积分，连续签到可累计递增积分，断签重置基础积分额度，每日仅限领取1次。 3. 互动任务：参与平台日常问卷、好物评价、话题互动等轻任务，根据任务难度可获取10-30积分/次，每日任务积分设有上限。 1. 用户在本APP商城、生活馆板块消费，按实际支付金额累积积分，常规比例为每实付1元累积1积分，积分四舍五入计算，运费、优惠券抵扣金额、退款金额不计入积分累积基数。 3. 订单支付成功后积分实时到账，若订单后续发生退款、取消、售后退货，平台将扣除对应已发放积分，积分不足时可抵扣现金或冻结后续积分权益。',
    );
  }

  @override
  Future<ApiResponse<StatementResult>> getStatements({required int page, required int pageSize, StatementType? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(const StatementResult(items: [], total: 0, page: 1, pageSize: 10, hasMore: false));
  }

  @override
  Future<ApiResponse<List<MemberAddress>>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success([
      const MemberAddress(
        id: 'addr_1',
        name: '张三',
        phone: '13800138000',
        province: '北京',
        city: '北京',
        district: '朝阳区',
        detail: '朝阳路 1 号',
        isDefault: true,
        label: '家',
      ),
    ]);
  }

  @override
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(address);
  }

  @override
  Future<ApiResponse<void>> deleteAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> setDefaultAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(const CustomerServiceInfo(phone: '400-800-8888', onlineUrl: 'https://example.com/service', workTime: '9:00-21:00'));
  }
}

/// MemberRepository Provider - 开发环境使用
final mockMemberRepositoryProvider = Provider<MemberRepository>((ref) => MockMemberDataSource());
