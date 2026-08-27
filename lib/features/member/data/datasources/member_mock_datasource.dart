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
    return ApiResponse.success(
      MemberLevelBenefits(level: level, name: level == 2 ? '银卡会员' : '会员', benefits: ['专享价', '免运费', '积分加速']),
    );
  }

  @override
  Future<ApiResponse<CouponListResult>> getCoupons({
    required int page,
    required int pageSize,
    CouponStatus? status,
  }) async {
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
      const PointsAccount(
        totalPoints: 3580,
        availablePoints: 3580,
        frozenPoints: 0,
        expiringPoints: 800,
        todayEarned: 10,
        totalEarned: 3580,
      ),
    );
  }

  @override
  Future<ApiResponse<PointsLogResult>> getPointsLogs({
    required int page,
    required int pageSize,
    PointsLogType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      PointsLogResult(
        logs: [
          PointsLog(
            id: 'log1',
            type: PointsLogType.earn,
            points: 10,
            balanceAfter: 3580,
            description: '每日签到',
            createTime: DateTime.now(),
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
  Future<ApiResponse<String>> getPointsRules() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success('积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月。');
  }

  @override
  Future<ApiResponse<StatementResult>> getStatements({
    required int page,
    required int pageSize,
    StatementType? type,
  }) async {
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
    return ApiResponse.success(
      const CustomerServiceInfo(
        phone: '400-800-8888',
        onlineUrl: 'https://example.com/service',
        workTime: '9:00-21:00',
      ),
    );
  }
}

/// MemberRepository Provider - 开发环境使用
final mockMemberRepositoryProvider = Provider<MemberRepository>((ref) => MockMemberDataSource());
