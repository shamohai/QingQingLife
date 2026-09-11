import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../data/models/points_mall_home_data.dart';
import '../../data/models/sign_in_result.dart';

/// Mock 积分商城数据源 - 开发/测试环境使用
class MockPointsDataSource implements PointsRepository {
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
    bannerUrls: ['assets/images/points/banner.jpg'],
    currentPoints: 143544,
    expiringPoints: 1200,
    expiryDate: DateTime(2026, 12, 31),
    rulesText:
        '1. 积分有效期为当年1月1日至次年12月31日\n2. 积分不可兑现、不可转让\n3. 积分兑换商品需支付运费\n4. 兑换成功后积分实时扣除',
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
      PointsProduct(
        id: 'h2',
        imageUrl: _img(1),
        name: '青藏高原枸杞特级 250g装',
        points: 800,
        stock: 300,
        salesCount: 456,
        tag: '爆款',
        type: PointsProductType.physical,
      ),
      PointsProduct(
        id: 'h3',
        imageUrl: _img(2),
        name: '青海牦牛肉干原味 100g',
        points: 600,
        stock: 200,
        salesCount: 88,
        tag: '特产',
        type: PointsProductType.physical,
      ),
      PointsProduct(
        id: 'h4',
        imageUrl: _img(3),
        name: '视频会员月卡 自动充值',
        points: 500,
        stock: 999,
        salesCount: 678,
        tag: '热销',
        type: PointsProductType.virtual,
      ),
    ],
    redeemableGroups: [
      PointsRedeemGroup(
        rangeLabel: '0~1000',
        products: [
          PointsProduct(
            id: 'r1',
            imageUrl: _img(0),
            name: '青海环线旅游券（三日）',
            points: 1000,
            stock: 500,
            salesCount: 123,
            type: PointsProductType.physical,
          ),
          PointsProduct(
            id: 'r2',
            imageUrl: _img(3),
            name: '视频会员月卡',
            points: 500,
            stock: 999,
            salesCount: 888,
            type: PointsProductType.virtual,
          ),
          PointsProduct(
            id: 'r3',
            imageUrl: _img(1),
            name: '青海枸杞 特级 250g',
            points: 800,
            stock: 200,
            salesCount: 345,
            type: PointsProductType.physical,
          ),
          PointsProduct(
            id: 'r4',
            imageUrl: _img(2),
            name: '牦牛肉干 原味 100g',
            points: 600,
            stock: 150,
            salesCount: 234,
            type: PointsProductType.physical,
          ),
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
          PointsProduct(
            id: 'r6',
            imageUrl: _img(5),
            name: '首单包邮权益卡',
            points: 2000,
            stock: 500,
            salesCount: 123,
            type: PointsProductType.service,
          ),
          PointsProduct(
            id: 'r7',
            imageUrl: _img(6),
            name: '青海湖一日游 电子票',
            points: 4500,
            stock: 80,
            salesCount: 90,
            tag: '限量',
            type: PointsProductType.service,
          ),
          PointsProduct(
            id: 'r8',
            imageUrl: _img(7),
            name: '藏香熏香礼盒 12支装',
            points: 1500,
            stock: 300,
            salesCount: 456,
            type: PointsProductType.physical,
          ),
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
          PointsProduct(
            id: 'r10',
            imageUrl: _img(3),
            name: '视频会员年卡',
            points: 8000,
            stock: 300,
            salesCount: 89,
            type: PointsProductType.virtual,
          ),
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
          PointsProduct(
            id: 'r12',
            imageUrl: _img(6),
            name: '青海深度游 三日套餐',
            points: 15000,
            stock: 10,
            salesCount: 33,
            tag: '热门',
            type: PointsProductType.service,
          ),
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
          PointsProduct(
            id: 'r14',
            imageUrl: _img(8),
            name: '智能家居套装（含智能音箱）',
            points: 25000,
            stock: 10,
            salesCount: 5,
            type: PointsProductType.physical,
          ),
        ],
      ),
    ],
  );

  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(_mockHomeData);
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({
    required int page,
    required int pageSize,
    String? categoryId,
    String? keyword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 300));
    final product = _mockHomeData.hotProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => _mockHomeData.hotProducts.first,
    );
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
    await Future.delayed(const Duration(milliseconds: 800));
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
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({
    required int page,
    required int pageSize,
    ExchangeStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
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
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(const SignInResult(
      success: true,
      pointsEarned: 10,
      consecutiveDays: 5,
      isConsecutiveBonus: false,
      bonusPoints: 0,
      message: '签到成功',
    ));
  }

  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(_mockHomeData.rulesText);
  }
}

/// Mock Repository Provider（开发环境已集成进 repository_providers.dart）
final mockPointsRepositoryProvider = Provider<PointsRepository>((ref) => MockPointsDataSource());
