import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/member_repository.dart';
import '../../../../core/network/api_response.dart';
import '../models/member_authority_model.dart';

/// Mock 会员数据源 - 开发/测试环境使用
///
/// TODO(Mock): 会员相关后端接口尚未实现，当前全部返回本地 Mock 数据。
/// Mock 值对齐设计稿：顾问级、成长值 778/10000、可尊享十项会员权益、2027-10-01 到期。
/// 后端就绪后，由 Remote 数据源替换（见 MemberRemoteDataSource）。
class MockMemberDataSource implements MemberRepository {
  /// 当前会员等级名（设计稿：顾问级）
  static const String levelName = '顾问级';

  /// 当前等级成长值 / 下一等级所需成长值（设计稿：778/10000）
  static const int growthValue = 778;
  static const int nextLevelGrowthValue = 10000;

  /// 等级到期时间戳（秒），与「我的」页展示的 2027-10-01 到期一致
  static const String effectiveTime = '1822320000';

  /// 会员权益宫格主列表（设计稿 18 项，等级越高开放越多）
  ///
  /// TODO(Mock): 名称/介绍以设计稿录入，后端 getmemberauthority 就绪后以接口返回为准；
  /// 其中「陪餐课」「醒脚酒吧」「回厂游」等文案为截图辨识结果，请以设计源核对。
  static const List<MemberAuthItem> gridBenefits = [
    MemberAuthItem(auth: 1, authname: '生日好礼', introduce: '礼盒+天之德', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 1),
    MemberAuthItem(auth: 2, authname: '生日好礼2', introduce: '礼盒+天之德*2', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 2),
    MemberAuthItem(auth: 3, authname: '陪餐课', introduce: '特牛火锅店', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 3),
    MemberAuthItem(auth: 4, authname: '醒脚酒吧', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 4),
    MemberAuthItem(auth: 5, authname: '美伦酒店', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 5),
    MemberAuthItem(auth: 6, authname: '接机&送机', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 6),
    MemberAuthItem(auth: 7, authname: '途虎', introduce: '养车洗车券', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 7),
    MemberAuthItem(auth: 8, authname: '彩虹部落', introduce: '门票', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 8),
    MemberAuthItem(auth: 9, authname: '回厂游', introduce: '凑一桌宴请*6人桌', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 9),
    MemberAuthItem(auth: 10, authname: '100元', introduce: '分享红包', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 10),
    MemberAuthItem(auth: 11, authname: '50元', introduce: '分享红包', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 11),
    MemberAuthItem(auth: 12, authname: '视频会员', introduce: '十一选一', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 12),
    MemberAuthItem(auth: 13, authname: '高尔夫跑团', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 13),
    MemberAuthItem(auth: 14, authname: '网羽中心', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 14),
    MemberAuthItem(auth: 15, authname: '露营基地', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 15),
    MemberAuthItem(auth: 16, authname: '视频会员', introduce: '五选一', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 16),
    MemberAuthItem(auth: 17, authname: '回厂游', introduce: '请一桌宴请*6人桌', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 17),
    MemberAuthItem(auth: 18, authname: '回厂游', introduce: '', isown: true, isuse: false, tipsmsg: '', newwelfare: false, sort: 18),
  ];

  /// 各等级权益开放数量（对应 level 1~5：人之德/家之德/国之德/天之德/顾问级）
  static const List<int> _levelGridCounts = [6, 9, 12, 15, 18];

  /// 会员等级卡片权益数（设计稿：顾问级为十项，与「我的」页展示一致）
  static List<String> get cardBenefitNames => gridBenefits.take(10).map((e) => e.authname).toList();

  @override
  Future<ApiResponse<MemberInfo>> getMemberInfo() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ApiResponse.success(
      const MemberInfo(
        id: 'u001',
        nickname: '青轻用户_9527',
        memberLevel: 2,
        levelName: levelName,
        growthValue: growthValue,
        nextLevelGrowthValue: nextLevelGrowthValue,
        points: 3580,
        availableCoupons: 5,
        hasHousekeeper: false,
      ),
    );
  }

  @override
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(MemberLevelBenefits(level: level, name: levelName, benefits: cardBenefitNames));
  }

  /// Mock 会员权益权限
  ///
  /// TODO(Mock): 权益接口 POST /api/sys/v2/getmemberauthority 后端尚未实现，
  /// 当前返回本地 Mock 数据用于 UI 还原；后端就绪后改由 MemberRemoteDataSource 提供。
  /// 等级越高开放权益越多（level 1~5 → 6/9/12/15/18 条）。
  @override
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final count = _levelGridCounts[(level - 1).clamp(0, _levelGridCounts.length - 1)];
    return ApiResponse.success(
      MemberAuthorityModel(
        auths: gridBenefits.take(count).toList(),
        level: level,
        effectivetime: effectiveTime,
        lowlevelcredit: 0,
        nextlevelcredit: nextLevelGrowthValue,
      ),
    );
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
      PointsAccount(
        totalPoints: 3580,
        availablePoints: 3580,
        frozenPoints: 0,
        expiringPoints: 800,
        expiringDate: DateTime.now().add(const Duration(days: 90)),
        todayEarned: 10,
        totalEarned: 3580,
      ),
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
    return ApiResponse.success('积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月。');
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
