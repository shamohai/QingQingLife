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

/// 积分商城远程数据源
///
/// 通过真实 API 获取积分商城相关数据。
class PointsRemoteDataSource implements PointsRepository {
  final ApiClient _apiClient;

  PointsRemoteDataSource({required this._apiClient});

  // ── 积分商城热门兑换商品（推荐位：CREDITMALL）───────────────────────────
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getCreditMallHotProducts() async {
    final response = await _apiClient.post<List<CreditMallProduct>>(
      '/api/product/getrecommendproductlist',
      data: {'positioncode': 'APP_CREDITMALL', 'topn': 20},
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
      '/api/product/getcreditproductcategory',
      data: {},
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
  }) async {
    final body = <String, dynamic>{
      'pageindex': page,
      'pagesize': pageSize,
      'minintegral': minIntegral ?? 0,
      'maxintegral': maxIntegral ?? 0,
      'categoryid': categoryId ?? 0,
    };
    if (exchangeable != null) body['exchangeable'] = exchangeable;
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
    throw UnimplementedError('getServiceProductDetail not implemented in PointsRemoteDataSource');
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
