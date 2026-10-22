import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart' show apiClientProvider;
import '../../../points_mall/data/models/points_mall_home_data.dart';
import '../../../points_mall/data/models/sign_in_result.dart';
import '../../../points_mall/data/models/service_product_detail_model.dart';
import '../../../points_mall/data/models/get_recommend_product_list_model.dart';
import '../../../points_mall/data/models/get_credit_product_list_model.dart';
import '../../../points_mall/data/models/credit_product_category_model.dart';

/// Mock 积分商城数据源 - 开发/测试环境使用
///
/// 除 getCreditMallHotProducts（热门兑换商品）对接真实 API 外，其余方法走 Mock 数据。
class MockPointsDataSource implements PointsRepository {
  MockPointsDataSource({this.apiClient});
  final ApiClient? apiClient;
  final _uuid = const Uuid();

  // 产品图片池，循环使用
  static const _productImages = [
    'assets/images/product/product1.jpg',
    'assets/images/product/product2.jpg',
    'assets/images/product/product3.jpg',
    'assets/images/product/product4.jpg',
    'assets/images/product/product5.jpg',
    'assets/images/product/product6.jpg',
    'assets/images/product/product7.jpg',
    'assets/images/product/product8.jpg',
    'assets/images/product/product9.jpg',
    'assets/images/product/product10.jpg',
  ];

  /// 辅助：按索引取图片
  static String _img(int index) => _productImages[index % _productImages.length];

  static PointsMallHomeData get _mockHomeData => PointsMallHomeData(
    bannerUrl: 'assets/images/points/banner.jpg',
    bannerUrls: ['assets/images/points/banner.jpg', 'assets/images/points/banner.jpg', 'assets/images/points/banner.jpg'],
    currentPoints: 143544,
    expiringPoints: 1200,
    expiryDate: DateTime(2026, 12, 31),
    rulesText: '1. 积分有效期为当年1月1日至次年12月31日，过期积分不予兑换\n2. 积分不可兑现、不可转让\n3. 积分兑换商品需支付运费\n4. 兑换成功后积分实时扣除',
    categories: [
      PointsCategory(id: 'all', label: '全部分类', iconUrl: ''),
      PointsCategory(id: 'local', label: '本地特色', iconUrl: ''),
      PointsCategory(id: 'service', label: '本地服务', iconUrl: ''),
      PointsCategory(id: 'coupon', label: '充值卡券', iconUrl: ''),
      PointsCategory(id: 'sports', label: '户外活动', iconUrl: ''),
      PointsCategory(id: 'media', label: '影视会员', iconUrl: ''),
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
      PointsProduct(id: 'h3', imageUrl: _img(2), name: '青海牦牛肉干原味 100g', points: 600, stock: 200, salesCount: 88, tag: '特产', type: PointsProductType.physical),
      PointsProduct(id: 'h4', imageUrl: _img(3), name: '视频会员月卡 自动充值', points: 500, stock: 999, salesCount: 678, tag: '热销', type: PointsProductType.virtual),
    ],
    redeemableGroups: [
      PointsRedeemGroup(
        rangeLabel: '0~1000',
        products: [
          PointsProduct(id: 'r1', imageUrl: _img(0), name: '青海环线旅游券（三日）', points: 1000, stock: 500, salesCount: 123, type: PointsProductType.physical),
          PointsProduct(id: 'r2', imageUrl: _img(3), name: '视频会员月卡', points: 500, stock: 999, salesCount: 888, type: PointsProductType.virtual),
          PointsProduct(id: 'r3', imageUrl: _img(1), name: '青海枸杞 特级 250g', points: 800, stock: 200, salesCount: 345, type: PointsProductType.physical),
          PointsProduct(id: 'r4', imageUrl: _img(2), name: '牦牛肉干 原味 100g', points: 600, stock: 150, salesCount: 234, type: PointsProductType.physical),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '1001~5000',
        products: [
          PointsProduct(
            id: 'r5',
            imageUrl: _img(4),
            name: '天佑德青稞酒 经典款 500ml',
            points: 3800,
            originalPoints: 4800,
            stock: 100,
            salesCount: 567,
            tag: '热门',
            type: PointsProductType.physical,
          ),
          PointsProduct(id: 'r6', imageUrl: _img(5), name: '首单包邮权益卡', points: 2000, stock: 500, salesCount: 123, type: PointsProductType.service),
          PointsProduct(id: 'r7', imageUrl: _img(6), name: '青海湖一日游 电子票', points: 4500, stock: 80, salesCount: 90, tag: '限量', type: PointsProductType.service),
          PointsProduct(id: 'r8', imageUrl: _img(7), name: '藏香熏香礼盒 12支装', points: 1500, stock: 300, salesCount: 456, type: PointsProductType.physical),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '5001~10000',
        products: [
          PointsProduct(
            id: 'r9',
            imageUrl: _img(8),
            name: '天佑德青稞酒 礼盒装 500ml×2',
            points: 7800,
            originalPoints: 9800,
            stock: 50,
            salesCount: 67,
            tag: '礼盒',
            type: PointsProductType.physical,
          ),
          PointsProduct(id: 'r10', imageUrl: _img(3), name: '视频会员年卡', points: 8000, stock: 300, salesCount: 89, type: PointsProductType.virtual),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '10001~20000',
        products: [
          PointsProduct(
            id: 'r11',
            imageUrl: _img(0),
            name: '高端青稞酒礼盒 500ml×6',
            points: 18800,
            originalPoints: 25800,
            stock: 20,
            salesCount: 12,
            tag: '旗舰',
            type: PointsProductType.physical,
          ),
          PointsProduct(id: 'r12', imageUrl: _img(6), name: '青海深度游 三日套餐', points: 15000, stock: 10, salesCount: 33, tag: '热门', type: PointsProductType.service),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '20000以上',
        products: [
          PointsProduct(
            id: 'r13',
            imageUrl: _img(4),
            name: '青稞酒珍藏版 礼盒 500ml×12',
            points: 38800,
            originalPoints: 48800,
            stock: 5,
            salesCount: 3,
            tag: '限量',
            type: PointsProductType.physical,
          ),
          PointsProduct(id: 'r14', imageUrl: _img(8), name: '智能家居套装（含智能音箱）', points: 25000, stock: 10, salesCount: 5, type: PointsProductType.physical),
        ],
      ),
    ],
  );

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
        productImageUrl: _img(0),
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
  Future<ApiResponse<ServiceProductDetail>> getServiceProductDetail(String productId) async {
    final client = apiClient;
    if (client != null) {
      try {
        final response = await client.post<ServiceProductDetail>(
          '/api/product/getproductinfo',
          data: <String, dynamic>{'pid': int.tryParse(productId) ?? 0},
          fromJson: (dynamic json) => ServiceProductDetail.fromJson(json as Map<String, dynamic>),
        );
        return response;
      } catch (e) {
        // 异常降级至 Mock 数据
      }
    }
    return ApiResponse.success(ServiceProductDetail.mock);
  }

  @override
  Future<ApiResponse<String>> getPointsRule() async {
    return ApiResponse.success(_mockHomeData.rulesText);
  }

  // Mock 青稞粒商品数据（覆盖各积分段，含 service 类型）
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
    {
      'productId': 3,
      'productType': 0,
      'productName': '青藏高原枸杞特级 250g装',
      'imgUrl': 'assets/images/product/product3.jpg',
      'creditPrice': 800,
      'praise': 92,
      'commentCount': 456,
      'storeId': 1,
    },
    {
      'productId': 4,
      'productType': 0,
      'productName': '青海牦牛肉干原味 100g',
      'imgUrl': 'assets/images/product/product4.jpg',
      'creditPrice': 600,
      'praise': 90,
      'commentCount': 88,
      'storeId': 1,
    },
    {
      'productId': 5,
      'productType': 11,
      'productName': '视频会员月卡 自动充值',
      'imgUrl': 'assets/images/product/product5.jpg',
      'creditPrice': 500,
      'praise': 96,
      'commentCount': 678,
      'storeId': 1,
    },
    {
      'productId': 6,
      'productType': 0,
      'productName': '藏香熏香礼盒 12支装',
      'imgUrl': 'assets/images/product/product6.jpg',
      'creditPrice': 1500,
      'praise': 88,
      'commentCount': 456,
      'storeId': 1,
    },
    {
      'productId': 7,
      'productType': 10,
      'productName': '青海湖一日游 电子票',
      'imgUrl': 'assets/images/product/product7.jpg',
      'creditPrice': 4500,
      'praise': 94,
      'commentCount': 90,
      'storeId': 1,
    },
    {
      'productId': 8,
      'productType': 0,
      'productName': '首单包邮权益卡',
      'imgUrl': 'assets/images/product/product8.jpg',
      'creditPrice': 2000,
      'praise': 91,
      'commentCount': 123,
      'storeId': 1,
    },
    {
      'productId': 9,
      'productType': 0,
      'productName': '天佑德青稞酒 礼盒装 500ml×2',
      'imgUrl': 'assets/images/product/product9.jpg',
      'creditPrice': 7800,
      'praise': 97,
      'commentCount': 67,
      'storeId': 1,
    },
    {
      'productId': 10,
      'productType': 2,
      'productName': '视频会员年卡',
      'imgUrl': 'assets/images/product/product10.jpg',
      'creditPrice': 8000,
      'praise': 93,
      'commentCount': 89,
      'storeId': 1,
    },
    {
      'productId': 11,
      'productType': 0,
      'productName': '高端青稞酒礼盒 500ml×6',
      'imgUrl': 'assets/images/product/product1.jpg',
      'creditPrice': 18800,
      'praise': 99,
      'commentCount': 12,
      'storeId': 1,
    },
    {
      'productId': 12,
      'productType': 10,
      'productName': '青海深度游 三日套餐',
      'imgUrl': 'assets/images/product/product3.jpg',
      'creditPrice': 15000,
      'praise': 96,
      'commentCount': 33,
      'storeId': 1,
    },
    {
      'productId': 13,
      'productType': 0,
      'productName': '青稞酒珍藏版 礼盒 500ml×12',
      'imgUrl': 'assets/images/product/product5.jpg',
      'creditPrice': 38800,
      'praise': 98,
      'commentCount': 3,
      'storeId': 1,
    },
    {
      'productId': 14,
      'productType': 0,
      'productName': '智能家居套装（含智能音箱）',
      'imgUrl': 'assets/images/product/product7.jpg',
      'creditPrice': 25000,
      'praise': 85,
      'commentCount': 5,
      'storeId': 1,
    },
  ];

  /// 获取推荐商品列表（推荐位接口）
  ///
  /// 通过 ApiClient 直接调用真实 API；未传入时返回空列表。
  @override
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode}) async {
    final client = apiClient;
    if (client == null) return ApiResponse.success([]);
    final response = await client.post<List<CreditMallProduct>>(
      '/api/product/getrecommendproductlist',
      data: {'positioncode': positionCode, 'topn': 20},
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
    final client = apiClient;
    if (client != null) {
      try {
        final response = await client.post<CreditProductCategoryData>(
          '/api/product/app/getcreditproductcategory',
          data: {},
          fromJson: (dynamic json) => CreditProductCategoryData.fromJson(json as Map<String, dynamic>),
        );
        return response;
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
  }) async {
    final client = apiClient;
    if (client != null) {
      try {
        final body = <String, dynamic>{
          'pageindex': page,
          'pagesize': pageSize,
          'minintegral': minIntegral ?? 0,
          'maxintegral': maxIntegral ?? 0,
          'categoryid': categoryId ?? 0,
        };
        if (exchangeable != null) body['exchangeable'] = exchangeable;
        final response = await client.post<CreditProductListData>(
          '/api/product/getcreditproductlist',
          data: body,
          fromJson: (dynamic json) => CreditProductListData.fromJson(json as Map<String, dynamic>),
        );
        return response;
      } catch (e) {
        // 异常降级至 Mock 数据
      }
    }

    var products = List<Map<String, dynamic>>.from(_mockCreditProducts);
    // 积分段筛选（0 表示不限制）
    if (minIntegral != null && minIntegral > 0) {
      products = products.where((p) => (p['creditPrice'] as int) >= minIntegral).toList();
    }
    if (maxIntegral != null && maxIntegral > 0) {
      products = products.where((p) => (p['creditPrice'] as int) <= maxIntegral).toList();
    }
    if (exchangeable != null) {
      // TODO: 对接真实 exchangeable 字段
    }
    // 分页
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
}

/// Mock Repository Provider - 开发环境使用
///
/// 注入 apiClientProvider 使 getRecommendProductList 可调用真实 API。
final mockPointsRepositoryProvider = Provider<PointsRepository>((ref) => MockPointsDataSource(apiClient: ref.read(apiClientProvider)));
