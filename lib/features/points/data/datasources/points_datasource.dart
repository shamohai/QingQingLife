import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/repositories/points_repository.dart';
import '../models/points_credit_detail_models.dart';
import '../../mall/data/models/credit_product_category_model.dart';
import '../../mall/data/models/get_credit_product_list_model.dart';
import '../../mall/data/models/get_recommend_product_list_model.dart';
import '../../mall/data/models/points_submit_order_models.dart';
import '../../mall/data/models/pre_credit_order_info_model.dart';

/// 统一积分数据源（实现 PointsRepository 接口）
///
/// 仅通过真实后端接口获取数据。接口不存在或请求失败时返回失败结果，
/// 由页面的 Error 状态承接，不伪造成功数据。
class PointsDataSource implements PointsRepository {
  final ApiClient apiClient;

  PointsDataSource({required this.apiClient});

  // ── 推荐商品列表（推荐位接口）───────────────────────────────────────────
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) async {
    return apiClient.post<List<CreditMallProduct>>(
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
    return apiClient.post<CreditProductCategoryData>(
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
    return apiClient.post<CreditProductListData>(
      '/api/product/getcreditproductlist',
      data: body,
      fromJson: (dynamic json) => CreditProductListData.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PointsCreditListData>> getCreditList({required int page, required int pageSize, String? startDate, String? endDate}) async {
    final body = <String, dynamic>{
      'pageindex': page,
      'pagesize': pageSize,
      if (startDate != null && startDate.isNotEmpty) 'startdate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'enddate': endDate,
    };
    return apiClient.post<PointsCreditListData>(
      '/api/promotion/getcreditlist',
      data: body,
      fromJson: (dynamic json) => PointsCreditListData.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({required int userServiceId, required String productId, required int quantity}) async {
    final pid = int.tryParse(productId) ?? 0;
    return apiClient.post<PreCreditOrderInfoModel>(
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
    return apiClient.post<SubmitCreditOrderResp>(
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
    return apiClient.post<SubmitServiceCouponIntegralOrderResp>(
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
    return apiClient.post<SubmitBaiLiHuiOrderResp>(
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
}
