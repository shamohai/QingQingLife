import '../../../../core/network/api_response.dart';
import '../../domain/repositories/points_repository.dart';
import '../datasources/points_mock_datasource.dart';
import '../datasources/points_remote_datasource.dart';
import '../models/points_credit_detail_models.dart';
import '../../mall/data/models/credit_product_category_model.dart';
import '../../mall/data/models/get_credit_product_list_model.dart';
import '../../mall/data/models/get_recommend_product_list_model.dart';
import '../../mall/data/models/points_mall_home_data.dart';
import '../../mall/data/models/points_submit_order_models.dart';
import '../../mall/data/models/pre_credit_order_info_model.dart';
import '../../mall/data/models/sign_in_result.dart';

/// Coordinates known API-backed operations and explicitly mocked operations
/// behind the single points repository contract.
class PointsRepositoryImpl implements PointsRepository {
  const PointsRepositoryImpl({required this.remote, required this.mock});

  final PointsRemoteDataSource remote;
  final MockPointsDataSource mock;

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() => mock.getPointsMallHome();

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) =>
      mock.getProducts(page: page, pageSize: pageSize, categoryId: categoryId, keyword: keyword);

  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) => mock.getProductDetail(productId);

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
  Future<ApiResponse<PointsCreditListData>> getCreditList({required int page, required int pageSize, String? startDate, String? endDate}) =>
      remote.getCreditList(page: page, pageSize: pageSize, startDate: startDate, endDate: endDate);

  @override
  Future<ApiResponse<SignInResult>> signIn() => mock.signIn();

  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) => mock.getSignInCalendar(year: year, month: month);

  @override
  Future<ApiResponse<String>> getPointsRule() => mock.getPointsRule();

  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) =>
      remote.getRecommendProductList(positionCode: positionCode);

  @override
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory() => remote.getCreditProductCategory();

  @override
  Future<ApiResponse<CreditProductListData>> getCreditProductList({
    required int page,
    required int pageSize,
    int? minIntegral,
    int? maxIntegral,
    bool? exchangeable,
    int? categoryId,
    String? keywords,
    int? sort,
    bool? asc,
  }) => remote.getCreditProductList(
    page: page,
    pageSize: pageSize,
    minIntegral: minIntegral,
    maxIntegral: maxIntegral,
    exchangeable: exchangeable,
    categoryId: categoryId,
    keywords: keywords,
    sort: sort,
    asc: asc,
  );

  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({required int userServiceId, required String productId, required int quantity}) =>
      remote.getPreCreditOrderInfo(userServiceId: userServiceId, productId: productId, quantity: quantity);

  @override
  Future<ApiResponse<SubmitCreditOrderResp>> submitCreditOrder(SubmitCreditOrderReq req) => remote.submitCreditOrder(req);

  @override
  Future<ApiResponse<SubmitServiceCouponIntegralOrderResp>> submitServiceCouponIntegralOrder(SubmitServiceCouponIntegralOrderReq req) =>
      remote.submitServiceCouponIntegralOrder(req);

  @override
  Future<ApiResponse<SubmitBaiLiHuiOrderResp>> submitBaiLiHuiOrder(SubmitBaiLiHuiOrderReq req) => remote.submitBaiLiHuiOrder(req);
}
