import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/points_repository.dart';
import '../models/points_credit_detail_models.dart';
import '../../mall/data/models/credit_product_category_model.dart';
import '../../mall/data/models/get_credit_product_list_model.dart';
import '../../mall/data/models/get_recommend_product_list_model.dart';
import '../../mall/data/models/points_mall_home_data.dart';
import '../../mall/data/models/points_submit_order_models.dart';
import '../../mall/data/models/pre_credit_order_info_model.dart';

/// 统一积分数据源（实现 PointsRepository 接口）
///
/// 仅通过真实后端接口获取数据。接口不存在或请求失败时返回失败结果，
/// 由页面的 Error 状态承接，不伪造成功数据。
class PointsDataSource implements PointsRepository {
  final ApiClient? apiClient;

  PointsDataSource({this.apiClient});

  static const _tag = 'PointsDataSource';

  /// 没有真实接口可用时统一返回的失败结果。
  static ApiResponse<T> _unavailable<T>(String api) {
    AppLogger.warning('积分接口未接入，已返回失败结果', module: _tag, event: api);
    return ApiResponse.error('该功能暂未开放，请稍后再试');
  }

  // ── 推荐商品列表（推荐位接口）───────────────────────────────────────────
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) async {
    final client = apiClient;
    if (client == null) return _unavailable('getRecommendProductList');
    return client.post<List<CreditMallProduct>>(
      '/api/product/getrecommendproductlist',
      data: <String, dynamic>{'positioncode': positionCode, 'topn': 20},
      fromJson: (dynamic json) {
        final map = json as Map<String, dynamic>;
        final productsJson = map['products'] as List<dynamic>? ?? [];
        return productsJson.map((e) => CreditMallProduct.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory() async {
    final client = apiClient;
    if (client == null) return _unavailable('getCreditProductCategory');
    return client.post<CreditProductCategoryData>(
      '/api/product/app/getcreditproductcategory',
      data: <String, dynamic>{},
      fromJson: (dynamic json) => CreditProductCategoryData.fromJson(json as Map<String, dynamic>),
    );
  }

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
  }) async {
    final client = apiClient;
    if (client == null) return _unavailable('getCreditProductList');
    final body = <String, dynamic>{
      'pageindex': page,
      'pagesize': pageSize,
      'minintegral': minIntegral ?? 0,
      'maxintegral': maxIntegral ?? 0,
      'categoryid': categoryId ?? 0,
      if (keywords != null && keywords.trim().isNotEmpty) 'keywords': keywords.trim(),
    };
    if (exchangeable != null) body['exchangeable'] = exchangeable;
    if (sort != null) body['sort'] = sort;
    if (asc != null) body['asc'] = asc;
    return client.post<CreditProductListData>(
      '/api/product/getcreditproductlist',
      data: body,
      fromJson: (dynamic json) => CreditProductListData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PointsCreditListData>> getCreditList({required int page, required int pageSize, String? startDate, String? endDate}) async {
    final client = apiClient;
    if (client == null) return _unavailable('getCreditList');
    final body = <String, dynamic>{
      'pageindex': page,
      'pagesize': pageSize,
      if (startDate != null && startDate.isNotEmpty) 'startdate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'enddate': endDate,
    };
    return client.post<PointsCreditListData>(
      '/api/promotion/getcreditlist',
      data: body,
      fromJson: (dynamic json) => PointsCreditListData.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({required int userServiceId, required String productId, required int quantity}) async {
    final client = apiClient;
    if (client == null) return _unavailable('getPreCreditOrderInfo');
    final pid = int.tryParse(productId) ?? 0;
    return client.post<PreCreditOrderInfoModel>(
      '/api/order/dealprecreditorderinfo',
      data: <String, dynamic>{
        'userserviceid': userServiceId,
        'isgiftcard': false,
        'productlist': [
          <String, dynamic>{'itemid': pid, 'num': quantity},
        ],
      },
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return PreCreditOrderInfoModel.fromJson(json);
        }
        return const PreCreditOrderInfoModel(recvrType: RecvrType.none);
      },
    );
  }

  @override
  Future<ApiResponse<SubmitCreditOrderResp>> submitCreditOrder(SubmitCreditOrderReq req) async {
    final client = apiClient;
    if (client == null) return _unavailable('submitCreditOrder');
    return client.post<SubmitCreditOrderResp>(
      '/api/order/submitcreditorder',
      data: req.toJson(),
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return SubmitCreditOrderResp.fromJson(json);
        }
        return const SubmitCreditOrderResp(result: -1, descr: '格式错误');
      },
    );
  }

  @override
  Future<ApiResponse<SubmitServiceCouponIntegralOrderResp>> submitServiceCouponIntegralOrder(SubmitServiceCouponIntegralOrderReq req) async {
    final client = apiClient;
    if (client == null) return _unavailable('submitServiceCouponIntegralOrder');
    return client.post<SubmitServiceCouponIntegralOrderResp>(
      '/api/order/v2/submitservicecouponintegralorder',
      data: req.toJson(),
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return SubmitServiceCouponIntegralOrderResp.fromJson(json);
        }
        return const SubmitServiceCouponIntegralOrderResp(result: -1, descr: '格式错误');
      },
    );
  }

  @override
  Future<ApiResponse<SubmitBaiLiHuiOrderResp>> submitBaiLiHuiOrder(SubmitBaiLiHuiOrderReq req) async {
    final client = apiClient;
    if (client == null) return _unavailable('submitBaiLiHuiOrder');
    return client.post<SubmitBaiLiHuiOrderResp>(
      '/api/order/submitbailihuiorder',
      data: req.toJson(),
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return SubmitBaiLiHuiOrderResp.fromJson(json);
        }
        return const SubmitBaiLiHuiOrderResp(result: -1, descr: '格式错误');
      },
    );
  }

  // ── 商城首页与商品分页：当前无真实接口可替代，统一返回失败结果 ─────────────

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() async => _unavailable('getPointsMallHome');

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) async =>
      _unavailable('getProducts');
}
