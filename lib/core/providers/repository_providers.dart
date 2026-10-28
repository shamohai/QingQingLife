import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_mixed_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../domain/repositories/auth_repository.dart';
import '../../features/cart/data/repositories/cart_page_mock_repository.dart';
import '../../features/cart/domain/repositories/cart_page_repository.dart';
import '../../features/member/data/datasources/member_mock_datasource.dart';
import '../../features/member/data/datasources/member_mixed_datasource.dart';
import '../../features/member/data/datasources/member_remote_datasource.dart';
import '../../features/member/data/datasources/member_sign_in_mock_datasource.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/member/domain/repositories/member_sign_in_repository.dart';
import '../../features/notification/data/datasources/notification_mock_datasource.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/order/data/datasources/invoice_mock_datasource.dart';
import '../../features/order/data/datasources/order_mock_datasource.dart';
import '../../features/order/data/datasources/order_remote_datasource.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/invoice_repository.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/points/data/datasources/points_mock_datasource.dart';
import '../../features/points/data/datasources/points_remote_datasource.dart';
import '../../features/points/domain/repositories/points_repository.dart';
import '../../features/product/data/datasources/product_mixed_datasource.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../network/providers.dart' show apiClientProvider;
import '../../features/points/data/models/points_credit_detail_models.dart';
import '../../features/points_mall/data/models/points_mall_home_data.dart';
import '../../features/points_mall/data/models/get_recommend_product_list_model.dart';
import '../../features/points_mall/data/models/get_credit_product_list_model.dart';
import '../../features/points_mall/data/models/credit_product_category_model.dart';
import '../../features/points_mall/data/models/service_product_detail_model.dart';
import '../../features/points_mall/data/models/pre_credit_order_info_model.dart';
import '../../features/points_mall/data/models/points_submit_order_models.dart';
import '../../features/points_mall/data/models/sign_in_result.dart';
import '../../../../core/network/api_response.dart';

part 'repository_providers.g.dart';

/// ============================================================
/// Repository Providers - 开发/测试环境使用 Mock 实现
/// 真实 API 就绪后，在此处切换为 Remote*Repository 实现
/// ============================================================

/// Auth Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthMixedDataSource(remote: ref.read(remoteAuthDataSourceProvider), mock: MockAuthDataSource());
}

/// Product Repository Provider
@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductMixedDataSource(apiClient: ref.read(apiClientProvider));
}

/// Cart Repository Provider
@riverpod
CartPageRepository cartRepository(Ref ref) {
  return const CartPageMockRepository();
}

/// Order Repository Provider
@riverpod
OrderRepository orderRepository(Ref ref) {
  return OrderRepositoryImpl(remote: ref.read(orderRemoteDataSourceProvider), legacy: MockOrderDataSource());
}

/// Invoice Repository Provider
@riverpod
InvoiceRepository invoiceRepository(Ref ref) {
  // TODO(Mock): 发票中心后端接口尚未定义，当前走 Mock。
  // 接口就绪后改为返回 Remote 实现。
  return MockInvoiceDataSource();
}

/// Member Repository Provider
@riverpod
MemberRepository memberRepository(Ref ref) {
  // 地址列表及已完成对接的会员接口走真实数据源，其余能力继续使用 Mock。
  return MemberMixedDataSource(remote: ref.read(memberRemoteDataSourceProvider), mock: MockMemberDataSource());
}

/// Member Sign In Repository Provider
@riverpod
MemberSignInRepository memberSignInRepository(Ref ref) {
  // TODO(Mock): 会员签到后端接口尚未提供，当前走 Mock。
  // 接口就绪后改为返回 MemberSignInRemoteDataSource。
  return MockMemberSignInDataSource();
}

/// Points Repository Provider
///
/// 积分商城未对接的能力继续保留 Mock；积分明细通过独立 remote 数据源走真实接口。
@riverpod
PointsRepository pointsRepository(Ref ref) {
  return PointsMixedDataSource(
    remote: ref.read(pointsRemoteDataSourceProvider),
    mock: MockPointsDataSource(apiClient: ref.read(apiClientProvider)),
  );
}

/// 仅将已经确认的积分流水能力切换为远程实现，避免影响积分商城其他能力。
class PointsMixedDataSource implements PointsRepository {
  const PointsMixedDataSource({required this.remote, required this.mock});

  final PointsRepository remote;
  final PointsRepository mock;

  @override
  Future<ApiResponse<PointsCreditListData>> getCreditList({required int page, required int pageSize, String? startDate, String? endDate}) =>
      remote.getCreditList(page: page, pageSize: pageSize, startDate: startDate, endDate: endDate);

  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) =>
      mock.getRecommendProductList(positionCode: positionCode);

  @override
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory() => mock.getCreditProductCategory();

  @override
  Future<ApiResponse<CreditProductListData>> getCreditProductList({
    required int page,
    required int pageSize,
    int? minIntegral,
    int? maxIntegral,
    bool? exchangeable,
    int? categoryId,
    int? sort,
    bool? asc,
  }) => mock.getCreditProductList(
    page: page,
    pageSize: pageSize,
    minIntegral: minIntegral,
    maxIntegral: maxIntegral,
    exchangeable: exchangeable,
    categoryId: categoryId,
    sort: sort,
    asc: asc,
  );

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() => mock.getPointsMallHome();
  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) =>
      mock.getProducts(page: page, pageSize: pageSize, categoryId: categoryId, keyword: keyword);
  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) => mock.getProductDetail(productId);
  @override
  Future<ApiResponse<ServiceProductDetail>> getServiceProductDetail(String productId) => mock.getServiceProductDetail(productId);
  @override
  Future<ApiResponse<PointsExchangeResult>> exchangePointsProduct({
    required String productId,
    required int quantity,
    required String addressId,
    String? remark,
  }) => mock.exchangePointsProduct(productId: productId, quantity: quantity, addressId: addressId, remark: remark);
  @override
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({required int page, required int pageSize, ExchangeStatus? status}) =>
      mock.getExchangeRecords(page: page, pageSize: pageSize, status: status);
  @override
  Future<ApiResponse<SignInResult>> signIn() => mock.signIn();
  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) => mock.getSignInCalendar(year: year, month: month);
  @override
  Future<ApiResponse<String>> getPointsRule() => mock.getPointsRule();
  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({required int userServiceId, required String productId, required int quantity}) =>
      mock.getPreCreditOrderInfo(userServiceId: userServiceId, productId: productId, quantity: quantity);
  @override
  Future<ApiResponse<SubmitCreditOrderResp>> submitCreditOrder(SubmitCreditOrderReq req) => mock.submitCreditOrder(req);
  @override
  Future<ApiResponse<SubmitServiceCouponIntegralOrderResp>> submitServiceCouponIntegralOrder(SubmitServiceCouponIntegralOrderReq req) =>
      mock.submitServiceCouponIntegralOrder(req);
  @override
  Future<ApiResponse<SubmitBaiLiHuiOrderResp>> submitBaiLiHuiOrder(SubmitBaiLiHuiOrderReq req) => mock.submitBaiLiHuiOrder(req);
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  // TODO(Mock): 通知中心后端接口尚未定义，当前走 Mock。
  // 接口就绪后改为返回 NotificationRemoteDataSource。
  return MockNotificationDataSource();
}

/// 所有 Repository Provider 的聚合
final allRepositoryProviders = [
  authRepositoryProvider,
  productRepositoryProvider,
  cartRepositoryProvider,
  orderRepositoryProvider,
  memberRepositoryProvider,
  memberSignInRepositoryProvider,
  pointsRepositoryProvider,
  notificationRepositoryProvider,
];
