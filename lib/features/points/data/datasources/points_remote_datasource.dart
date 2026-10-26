import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/repositories/points_repository.dart';
import '../../../points_mall/data/models/get_recommend_product_list_model.dart';
import '../../../points_mall/data/models/points_mall_home_data.dart';
import '../../../points_mall/data/models/sign_in_result.dart';
import '../../../points_mall/data/models/service_product_detail_model.dart';
import '../../../points_mall/data/models/get_credit_product_list_model.dart';
import '../../../points_mall/data/models/credit_product_category_model.dart';
import '../../../points_mall/data/models/pre_credit_order_info_model.dart';
import '../../../points_mall/data/models/points_submit_order_models.dart';

/// 积分商城远程数据源
///
/// 通过真实 API 获取积分商城相关数据。
class PointsRemoteDataSource implements PointsRepository {
  final ApiClient _apiClient;

  PointsRemoteDataSource({required this._apiClient});

  // ── 推荐商品列表（推荐位接口）───────────────────────────────────────────
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) async {
    final response = await _apiClient.post<List<CreditMallProduct>>(
      '/api/product/getrecommendproductlist',
      data: <String, dynamic>{'positioncode': positionCode, 'topn': 20},
      fromJson: (dynamic json) {
        final map = json as Map<String, dynamic>;
        final productsJson = map['products'] as List<dynamic>? ?? [];
        return productsJson.map((e) => CreditMallProduct.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    return response;
  }

  @override
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory() async {
    return _apiClient.post<CreditProductCategoryData>(
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
    int? sort,
    bool? asc,
  }) async {
    final body = <String, dynamic>{
      'pageindex': page,
      'pagesize': pageSize,
      'minintegral': minIntegral ?? 0,
      'maxintegral': maxIntegral ?? 0,
      'categoryid': categoryId ?? 0,
    };
    if (exchangeable != null) body['exchangeable'] = exchangeable;
    if (sort != null) body['sort'] = sort;
    if (asc != null) body['asc'] = asc;
    return _apiClient.post<CreditProductListData>(
      '/api/product/getcreditproductlist',
      data: body,
      fromJson: (dynamic json) => CreditProductListData.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── 以下方法保留为占位，待对应接口就绪后实现 ──────────────────────────

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() async {
    throw UnimplementedError('getPointsMallHome not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) async {
    throw UnimplementedError('getProducts not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) async {
    throw UnimplementedError('getProductDetail not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<ServiceProductDetail>> getServiceProductDetail(String productId) async {
    return _apiClient.post<ServiceProductDetail>(
      '/api/product/getproductinfo',
      data: <String, dynamic>{'pid': int.tryParse(productId) ?? 0},
      fromJson: (dynamic json) => ServiceProductDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({
    required int userServiceId,
    required String productId,
    required int quantity,
  }) async {
    final pid = int.tryParse(productId) ?? 0;
    return _apiClient.post<PreCreditOrderInfoModel>(
      '/api/order/dealprecreditorderinfo',
      data: <String, dynamic>{
        'userserviceid': userServiceId,
        'isgiftcard': false,
        'productlist': [
          <String, dynamic>{
            'itemid': pid,
            'num': quantity,
          }
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
    return _apiClient.post<SubmitCreditOrderResp>(
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
    return _apiClient.post<SubmitServiceCouponIntegralOrderResp>(
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
    return _apiClient.post<SubmitBaiLiHuiOrderResp>(
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

  @override
  Future<ApiResponse<PointsExchangeResult>> exchangePointsProduct({
    required String productId,
    required int quantity,
    required String addressId,
    String? remark,
  }) async {
    throw UnimplementedError('exchangePointsProduct not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({required int page, required int pageSize, ExchangeStatus? status}) async {
    throw UnimplementedError('getExchangeRecords not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<SignInResult>> signIn() async {
    throw UnimplementedError('signIn not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) async {
    throw UnimplementedError('getSignInCalendar not implemented in PointsRemoteDataSource');
  }

  @override
  Future<ApiResponse<String>> getPointsRule() async {
    throw UnimplementedError('getPointsRule not implemented in PointsRemoteDataSource');
  }
}

final pointsRemoteDataSourceProvider = Provider<PointsRemoteDataSource>((ref) {
  return PointsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});
