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
  @override
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) async {
    return ApiResponse.success(MemberAuthorityModel(level: level, auths: gridBenefits.take(_levelGridCounts[level - 1]).toList()));
  }

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
    return ApiResponse.success(
      const MemberInfo(
        // TODO(Mock): UID 对齐设计稿，后端 getmemberinfo 就绪后以接口返回为准
        id: '434543456576543',
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
    return ApiResponse.success(MemberLevelBenefits(level: level, name: level == 2 ? '银卡会员' : '会员', benefits: ['专享价', '免运费', '积分加速']));
  }

  @override
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status}) async {
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
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<PointsAccount>> getPointsAccount() async {
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
    return ApiResponse.success(
      '为规范青轻生活APP（以下简称“本APP”）积分商城运营，保障全体用户合法权益，明确积分获取、使用、兑换、失效等相关规则，营造公平、有序的平台消费体验，特制定本积分规则。本规则适用于所有注册并使用本APP积分商城功能的用户，开通积分功能即视为自愿认可并遵守本规则全部条款。 一、积分基本定义 1. 青轻积分是本APP专属虚拟权益，仅可在青轻生活APP积分商城内使用，为用户专属消费兑换凭证，不支持提现、转账、售卖、折现、透支，不可兑换现金、不找零、不开发票，仅限本人账户使用，严禁跨账户转移、合并积分。 2. 积分分为累积积分与可用积分：累积积分是用户历史累计获得的全部积分总和，可作为用户平台活跃度、会员等级评定依据；可用积分是扣除已兑换、冻结、失效积分后，可正常用于商城兑换、权益抵扣的有效积分，日常消费兑换仅扣除可用积分。 二、积分获取规则 （一）新手专属积分 2. 新手完善资料：新用户完成头像、昵称、收货地址等基础资料完善，额外领取50积分，一次性领取。 1. 每日签到：用户每日登录APP完成签到，可领取5-15随机积分，连续签到可累计递增积分，断签重置基础积分额度，每日仅限领取1次。 3. 互动任务：参与平台日常问卷、好物评价、话题互动等轻任务，根据任务难度可获取10-30积分/次，每日任务积分设有上限。 1. 用户在本APP商城、生活板块消费，按实际支付金额累积积分，常规比例为每实付1元累积1积分，积分四舍五入计算，运费、优惠券抵扣金额、退款金额不计入积分累积基数。 3. 订单支付成功后积分实时到账，若订单后续发生退款、取消、售后退货，平台将扣除对应已发放积分，积分不足时可抵扣现金或冻结后续积分权益。',
    );
  }

  @override
  Future<ApiResponse<StatementResult>> getStatements({required int page, required int pageSize, StatementType? type}) async {
    return ApiResponse.success(const StatementResult(items: [], total: 0, page: 1, pageSize: 10, hasMore: false));
  }

  /// 内存态地址列表（Mock 期间模拟新增 / 编辑 / 删除 / 默认地址切换，重启后重置；
  /// 后端地址接口就绪后由 Remote 数据源替换）
  // TODO(Mock): 地址内容对齐设计稿，后端地址接口就绪后以接口返回为准
  final List<MemberAddress> _addresses = [
    const MemberAddress(
      id: 'addr_1',
      name: '吴彦祖',
      phone: '13099876878',
      province: '甘肃省',
      city: '兰州市',
      district: '七里河区',
      detail: '建兰路街道兰州中心办公楼801室',
      isDefault: true,
    ),
    const MemberAddress(
      id: 'addr_2',
      name: '吴彦祖',
      phone: '13099876878',
      province: '甘肃省',
      city: '兰州市',
      district: '七里河区',
      detail: '建兰路街道兰州中心办公楼801室',
      isDefault: false,
    ),
  ];

  /// 新增地址的自增 ID
  int _addressIdSeq = 3;

  @override
  Future<ApiResponse<List<MemberAddress>>> getAddresses() async {
    return ApiResponse.success(List.of(_addresses));
  }

  @override
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) async {
    if (address.id == null) {
      // 新增
      final created = address.copyWith(id: 'addr_${_addressIdSeq++}');
      _addresses.add(created);
      if (created.isDefault) _applyDefaultAddress(created.id!);
      return ApiResponse.success(created);
    }
    // 编辑
    final index = _addresses.indexWhere((e) => e.id == address.id);
    if (index < 0) return ApiResponse.error('地址不存在');
    _addresses[index] = address;
    if (address.isDefault) _applyDefaultAddress(address.id!);
    return ApiResponse.success(address);
  }

  @override
  Future<ApiResponse<void>> deleteAddress(String addressId) async {
    _addresses.removeWhere((e) => e.id == addressId);
    return ApiResponse.success(null);
  }

  @override
  Future<ApiResponse<void>> setDefaultAddress(String addressId) async {
    _applyDefaultAddress(addressId);
    return ApiResponse.success(null);
  }

  /// 将指定地址设为唯一默认地址
  void _applyDefaultAddress(String addressId) {
    for (var i = 0; i < _addresses.length; i++) {
      final item = _addresses[i];
      final shouldBeDefault = item.id == addressId;
      if (item.isDefault != shouldBeDefault) {
        _addresses[i] = item.copyWith(isDefault: shouldBeDefault);
      }
    }
  }

  @override
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService() async {
    return ApiResponse.success(const CustomerServiceInfo(phone: '400-800-8888', onlineUrl: 'https://example.com/service', workTime: '9:00-21:00'));
  }
}

/// MemberRepository Provider - 开发环境使用
final mockMemberRepositoryProvider = Provider<MemberRepository>((ref) => MockMemberDataSource());
