import '../../../../core/network/api_response.dart';
import '../../domain/repositories/member_repository.dart';
import '../models/member_authority_model.dart';
import '../models/coupon_group_model.dart';
import '../models/service_coupon_model.dart';
import '../models/member_rank_models.dart';
import 'member_mock_datasource.dart';
import 'member_remote_datasource.dart';

/// 过渡期混合会员数据源
///
/// 后端能力尚未全部就绪，按方法拆分数据源：
///   - 会员等级列表（getRankList）：POST /api/sys/app/getranklist，已接真实接口。
///   - 等级权益明细（getRankDetail）：POST /api/sys/app/getrankdetail，已接真实接口。
///   - 用户地址列表（getAddresses）：POST /api/sys/getuseraddresslist，已接真实接口。
///   - 我的优惠券分组列表（getCouponGroupList）：POST /api/promotion/getcoupongrouplist，已接真实接口。
///   - 地址删除、设为默认及其余会员能力（会员信息 / 等级权益 / 权益权限 / 通用优惠券 / 积分 / 客服）：
///     后端仍开发中，走 Mock。
///
/// 切换方式见 `lib/core/providers/repository_providers.dart` 中的 `memberRepository`：
///   - 当前：`MemberMixedDataSource(remote: ..., mock: ...)`（已完成接口走真实接口，其余 Mock）
///   - 全部接口就绪后：删除本类，直接 `return ref.read(memberRemoteDataSourceProvider);`
///   - 需要整体回退 Mock：直接 `return MockMemberDataSource();`
class MemberMixedDataSource implements MemberRepository {
  final MemberRemoteDataSource remote;
  final MockMemberDataSource mock;

  MemberMixedDataSource({required this.remote, required this.mock});

  // ── 已对接真实接口：会员等级列表 / 等级权益明细 ──────────────
  @override
  Future<ApiResponse<GetRankListResp>> getRankList() => remote.getRankList();

  @override
  Future<ApiResponse<GetRankDetailResp>> getRankDetail({required int level}) => remote.getRankDetail(level: level);

  @override
  Future<ApiResponse<ReceiveUserServiceResult>> receiveUserService({required int serviceId}) => remote.receiveUserService(serviceId: serviceId);

  @override
  Future<ApiResponse<CompleteUserInfoResult>> completeUserInfo({required String username, required int gender, required DateTime birthday}) =>
      remote.completeUserInfo(username: username, gender: gender, birthday: birthday);

  // ── 已对接真实接口：用户收货地址 ───────────────────────────
  @override
  Future<ApiResponse<List<MemberAddress>>> getAddresses({int addressId = 0}) => remote.getAddresses(addressId: addressId);

  @override
  Future<ApiResponse<MemberAddress>> saveAddress(MemberAddress address) => remote.saveAddress(address);

  // ── 后端未就绪：以下会员能力仍走 Mock ──────────────────────
  @override
  Future<ApiResponse<MemberInfo>> getMemberInfo() => mock.getMemberInfo();

  @override
  Future<ApiResponse<MemberLevelBenefits>> getLevelBenefits(int level) => mock.getLevelBenefits(level);

  @override
  Future<ApiResponse<MemberAuthorityModel>> getMemberAuthority({required int level}) => mock.getMemberAuthority(level: level);

  @override
  Future<ApiResponse<CouponGroupListResult>> getCouponGroupList({required CouponGroupStatus status}) => remote.getCouponGroupList(status: status);

  @override
  Future<ApiResponse<ServiceCouponListResult>> getServiceCouponList({required ServiceCouponStatus status, bool selfSetOnly = false}) =>
      remote.getServiceCouponList(status: status, selfSetOnly: selfSetOnly);

  @override
  Future<ApiResponse<ServiceCouponInfoResult>> refreshServiceCouponInfoV2({required int couponTypeId, required int count, String? preferCouponSn}) =>
      remote.refreshServiceCouponInfoV2(couponTypeId: couponTypeId, count: count, preferCouponSn: preferCouponSn);

  @override
  Future<ApiResponse<void>> giveServiceCoupon({required int serviceCouponId, required int count}) =>
      remote.giveServiceCoupon(serviceCouponId: serviceCouponId, count: count);

  @override
  Future<ApiResponse<CouponListResult>> getCoupons({required int page, required int pageSize, CouponStatus? status}) =>
      mock.getCoupons(page: page, pageSize: pageSize, status: status);

  @override
  Future<ApiResponse<void>> claimCoupon(String couponTemplateId) => mock.claimCoupon(couponTemplateId);

  @override
  Future<ApiResponse<PointsAccount>> getPointsAccount() => mock.getPointsAccount();

  @override
  Future<ApiResponse<PointsLogResult>> getPointsLogs({required int page, required int pageSize, PointsLogType? type}) =>
      mock.getPointsLogs(page: page, pageSize: pageSize, type: type);

  @override
  Future<ApiResponse<String>> getPointsRules() => mock.getPointsRules();

  @override
  Future<ApiResponse<StatementResult>> getStatements({required int page, required int pageSize, StatementType? type}) =>
      mock.getStatements(page: page, pageSize: pageSize, type: type);

  @override
  Future<ApiResponse<void>> deleteAddress(String addressId) => mock.deleteAddress(addressId);

  @override
  Future<ApiResponse<void>> setDefaultAddress(String addressId) => mock.setDefaultAddress(addressId);

  @override
  Future<ApiResponse<CustomerServiceInfo>> getCustomerService() => mock.getCustomerService();
}
