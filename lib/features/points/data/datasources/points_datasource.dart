import 'package:uuid/uuid.dart';

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
import '../../mall/data/models/sign_in_result.dart';

/// 统一积分数据源（实现 PointsRepository 接口）
///
/// 整合网络 API 与本地降级兜底逻辑，统一维护积分商城、流水及订单能力。
class PointsDataSource implements PointsRepository {
  final ApiClient? apiClient;
  final _uuid = const Uuid();

  PointsDataSource({this.apiClient});

  // ── 推荐商品列表（推荐位接口）───────────────────────────────────────────
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) async {
    if (apiClient != null) {
      final response = await apiClient!.post<List<CreditMallProduct>>(
        '/api/product/getrecommendproductlist',
        data: <String, dynamic>{'positioncode': positionCode, 'topn': 20},
        fromJson: (dynamic json) {
          final map = json as Map<String, dynamic>;
          final productsJson = map['products'] as List<dynamic>? ?? [];
          return productsJson.map((e) => CreditMallProduct.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
      if (response.success) return response;
    }
    return ApiResponse.success([]);
  }

  @override
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory() async {
    if (apiClient != null) {
      try {
        final response = await apiClient!.post<CreditProductCategoryData>(
          '/api/product/app/getcreditproductcategory',
          data: <String, dynamic>{},
          fromJson: (dynamic json) => CreditProductCategoryData.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }
    return ApiResponse.success(CreditProductCategoryData(categories: []));
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
    if (apiClient != null) {
      try {
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
        final response = await apiClient!.post<CreditProductListData>(
          '/api/product/getcreditproductlist',
          data: body,
          fromJson: (dynamic json) => CreditProductListData.fromJson(json as Map<String, dynamic>),
        );
        if (response.success) return response;
      } catch (_) {}
    }

    // 降级兜底数据
    var products = List<Map<String, dynamic>>.from(_mockCreditProducts);
    final normalizedKeyword = keywords?.trim().toLowerCase();
    if (normalizedKeyword != null && normalizedKeyword.isNotEmpty) {
      products = products.where((product) => (product['productName'] as String? ?? '').toLowerCase().contains(normalizedKeyword)).toList();
    }
    if (minIntegral != null && minIntegral > 0) {
      products = products.where((p) => (p['creditPrice'] as int) >= minIntegral).toList();
    }
    if (maxIntegral != null && maxIntegral > 0) {
      products = products.where((p) => (p['creditPrice'] as int) <= maxIntegral).toList();
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final pageProducts = start < products.length ? products.sublist(start, end.clamp(0, products.length)) : <Map<String, dynamic>>[];
    return ApiResponse.success(
      CreditProductListData(
        products: pageProducts
            .map(
              (p) => CreditProductItem(
                productId: p['productId'] as int,
                productType: CreditProductType.fromJson(p['productType']),
                productName: p['productName'] as String,
                imgUrl: p['imgUrl'] as String,
                creditPrice: p['creditPrice'] as int,
                praise: p['praise'] as int,
                commentCount: p['commentCount'] as int,
                storeId: p['storeId'] as int,
                isCredit: (p['isCredit'] as bool?) ?? (p['iscredit'] as bool?) ?? false,
              ),
            )
            .toList(),
        total: products.length,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<ApiResponse<PointsCreditListData>> getCreditList({required int page, required int pageSize, String? startDate, String? endDate}) async {
    if (apiClient != null) {
      final body = <String, dynamic>{
        'pageindex': page,
        'pagesize': pageSize,
        if (startDate != null && startDate.isNotEmpty) 'startdate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'enddate': endDate,
      };
      final response = await apiClient!.post<PointsCreditListData>(
        '/api/promotion/getcreditlist',
        data: body,
        fromJson: (dynamic json) => PointsCreditListData.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      if (response.success) return response;
    }
    return ApiResponse.success(const PointsCreditListData(totalDecrease: 0, totalCredit: 0, totalIncrease: 0, totalRecords: 0, credits: []));
  }

  @override
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({required int userServiceId, required String productId, required int quantity}) async {
    if (apiClient != null) {
      final pid = int.tryParse(productId) ?? 0;
      final response = await apiClient!.post<PreCreditOrderInfoModel>(
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
      if (response.success) return response;
    }
    return ApiResponse.success(const PreCreditOrderInfoModel(recvrType: RecvrType.shipAddress));
  }

  @override
  Future<ApiResponse<SubmitCreditOrderResp>> submitCreditOrder(SubmitCreditOrderReq req) async {
    if (apiClient != null) {
      final response = await apiClient!.post<SubmitCreditOrderResp>(
        '/api/order/submitcreditorder',
        data: req.toJson(),
        fromJson: (dynamic json) {
          if (json is Map<String, dynamic>) {
            return SubmitCreditOrderResp.fromJson(json);
          }
          return const SubmitCreditOrderResp(result: -1, descr: '格式错误');
        },
      );
      if (response.success) return response;
    }
    return ApiResponse.success(const SubmitCreditOrderResp(result: 0, descr: '提交成功', orderIds: [88001]));
  }

  @override
  Future<ApiResponse<SubmitServiceCouponIntegralOrderResp>> submitServiceCouponIntegralOrder(SubmitServiceCouponIntegralOrderReq req) async {
    if (apiClient != null) {
      final response = await apiClient!.post<SubmitServiceCouponIntegralOrderResp>(
        '/api/order/v2/submitservicecouponintegralorder',
        data: req.toJson(),
        fromJson: (dynamic json) {
          if (json is Map<String, dynamic>) {
            return SubmitServiceCouponIntegralOrderResp.fromJson(json);
          }
          return const SubmitServiceCouponIntegralOrderResp(result: -1, descr: '格式错误');
        },
      );
      if (response.success) return response;
    }
    return ApiResponse.success(const SubmitServiceCouponIntegralOrderResp(result: 0, descr: '提交成功', orderId: 88002));
  }

  @override
  Future<ApiResponse<SubmitBaiLiHuiOrderResp>> submitBaiLiHuiOrder(SubmitBaiLiHuiOrderReq req) async {
    if (apiClient != null) {
      final response = await apiClient!.post<SubmitBaiLiHuiOrderResp>(
        '/api/order/submitbailihuiorder',
        data: req.toJson(),
        fromJson: (dynamic json) {
          if (json is Map<String, dynamic>) {
            return SubmitBaiLiHuiOrderResp.fromJson(json);
          }
          return const SubmitBaiLiHuiOrderResp(result: -1, descr: '格式错误');
        },
      );
      if (response.success) return response;
    }
    return ApiResponse.success(const SubmitBaiLiHuiOrderResp(result: 0, descr: '提交成功', orderId: 88003));
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() async {
    return ApiResponse.success(_mockHomeData);
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) async {
    var products = List<PointsProduct>.from(_mockHomeData.hotProducts);
    if (categoryId != null && categoryId != 'all') {
      switch (categoryId) {
        case 'local':
          products = products.where((p) => p.type == PointsProductType.physical).toList();
        case 'coupon':
          products = products.where((p) => p.type == PointsProductType.virtual).toList();
        case 'media':
        case 'sports':
          products = products.where((p) => p.type == PointsProductType.service).toList();
        default:
          break;
      }
    }
    if (keyword != null && keyword.isNotEmpty) {
      products = products.where((p) => p.name.contains(keyword)).toList();
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final paginated = start < products.length ? products.sublist(start, end.clamp(0, products.length)) : <PointsProduct>[];
    return ApiResponse.success(
      PointsMallHomeData(
        bannerUrl: _mockHomeData.bannerUrl,
        bannerUrls: _mockHomeData.bannerUrls,
        currentPoints: _mockHomeData.currentPoints,
        expiringPoints: _mockHomeData.expiringPoints,
        expiryDate: _mockHomeData.expiryDate,
        rulesText: _mockHomeData.rulesText,
        categories: _mockHomeData.categories,
        hotProducts: paginated,
        redeemableGroups: _mockHomeData.redeemableGroups,
      ),
    );
  }

  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) async {
    final product = _mockHomeData.hotProducts.firstWhere((p) => p.id == productId, orElse: () => _mockHomeData.hotProducts.first);
    return ApiResponse.success(
      PointsProductDetail(
        id: product.id,
        name: product.name,
        description: '${product.name}，品质优良，值得兑换。',
        images: [product.imageUrl, product.imageUrl, product.imageUrl],
        points: product.points,
        stock: product.stock,
        skus: [],
        rulesText: '兑换规则：1. 每用户限兑1次 2. 需支付运费 3. 7天内发货',
        type: product.type,
        maxExchangePerUser: 1,
        exchangedCount: product.salesCount,
      ),
    );
  }

  @override
  Future<ApiResponse<PointsExchangeResult>> exchangePointsProduct({
    required String productId,
    required int quantity,
    required String addressId,
    String? remark,
  }) async {
    return ApiResponse.success(
      PointsExchangeResult(
        orderId: _uuid.v4(),
        orderNo: 'P${DateTime.now().millisecondsSinceEpoch}',
        pointsDeducted: quantity * 1000,
        status: ExchangeStatus.pending,
      ),
    );
  }

  @override
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({required int page, required int pageSize, ExchangeStatus? status}) async {
    return ApiResponse.success([
      PointsExchangeRecord(
        id: 'r1',
        exchangeNo: 'EX20250101001',
        productId: 'h1',
        productName: '天佑德电商专供青海环线旅游券（青海三日游）',
        productImageUrl: 'assets/images/product/product1.jpg',
        pointsDeducted: 1000,
        quantity: 1,
        status: ExchangeStatus.completed,
        statusText: '已完成',
        createTime: DateTime.now().subtract(const Duration(days: 10)),
        shipTime: DateTime.now().subtract(const Duration(days: 8)),
        receiveTime: DateTime.now().subtract(const Duration(days: 5)),
        logisticsCompany: '顺丰速运',
        logisticsNo: 'SF1234567890',
      ),
    ]);
  }

  @override
  Future<ApiResponse<SignInResult>> signIn() async {
    return ApiResponse.success(
      const SignInResult(success: true, pointsEarned: 10, consecutiveDays: 5, isConsecutiveBonus: false, bonusPoints: 0, message: '签到成功'),
    );
  }

  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) async {
    return ApiResponse.success(
      SignInCalendarResult(
        year: year,
        month: month,
        records: const [
          SignInDayRecord(day: 1, isSigned: true, pointsEarned: 10, isToday: false),
          SignInDayRecord(day: 2, isSigned: true, pointsEarned: 10, isToday: false),
        ],
        totalSignedDays: 5,
        consecutiveDays: 5,
      ),
    );
  }

  @override
  Future<ApiResponse<String>> getPointsRule() async {
    return ApiResponse.success(_mockHomeData.rulesText);
  }

  static const _productImages = [
    'assets/images/product/product1.jpg',
    'assets/images/product/product2.jpg',
    'assets/images/product/product3.jpg',
    'assets/images/product/product4.jpg',
    'assets/images/product/product5.jpg',
  ];

  static String _img(int index) => _productImages[index % _productImages.length];

  static PointsMallHomeData get _mockHomeData => PointsMallHomeData(
    bannerUrl: 'assets/images/points/banner.jpg',
    bannerUrls: ['assets/images/points/banner.jpg'],
    currentPoints: 143544,
    expiringPoints: 1200,
    expiryDate: DateTime(2026, 12, 31),
    rulesText: '1. 积分有效期为当年1月1日至次年12月31日\n2. 积分不可兑现、不可转让\n3. 兑换成功后积分实时扣除',
    categories: [
      PointsCategory(id: 'all', label: '全部分类', iconUrl: ''),
      PointsCategory(id: 'local', label: '本地特色', iconUrl: ''),
      PointsCategory(id: 'service', label: '本地服务', iconUrl: ''),
      PointsCategory(id: 'coupon', label: '充值卡券', iconUrl: ''),
    ],
    hotProducts: [
      PointsProduct(
        id: 'h1',
        imageUrl: _img(0),
        name: '天佑德电商专供青海环线旅游券（青海三日游）',
        points: 1000,
        stock: 500,
        salesCount: 123,
        tag: '热门',
        type: PointsProductType.physical,
      ),
      PointsProduct(id: 'h2', imageUrl: _img(1), name: '青藏高原枸杞特级 250g装', points: 800, stock: 300, salesCount: 456, tag: '爆款', type: PointsProductType.physical),
    ],
    redeemableGroups: [],
  );

  static const _mockCreditProducts = [
    {
      'productId': 1,
      'productType': 0,
      'productName': '天佑德青稞酒 经典款 500ml',
      'imgUrl': 'assets/images/product/product1.jpg',
      'creditPrice': 3800,
      'praise': 98,
      'commentCount': 567,
      'storeId': 1,
    },
    {
      'productId': 2,
      'productType': 10,
      'productName': '青海环线旅游券（三日）',
      'imgUrl': 'assets/images/product/product2.jpg',
      'creditPrice': 1000,
      'praise': 95,
      'commentCount': 123,
      'storeId': 1,
    },
  ];
}
