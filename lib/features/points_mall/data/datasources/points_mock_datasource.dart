import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../data/models/points_mall_home_data.dart';
import '../../data/models/sign_in_result.dart';

/// Mock 积分商城数据源 - 开发/测试环境使用
class MockPointsDataSource implements PointsRepository {
  final _uuid = const Uuid();

  static final _mockHomeData = PointsMallHomeData(
    bannerUrl: 'assets/images/points/banner.jpg',
    bannerUrls: const [
      'assets/images/points/banner.jpg',
      'assets/images/points/banner.jpg',
      'assets/images/points/banner.jpg',
    ],
    currentPoints: 143588,
    expiringPoints: 1200,
    expiryDate: DateTime(2026, 12, 31),
    rulesText: '1. 积分有效期为当年1月1日至次年12月31日\n2. 积分不可兑现、不可转让\n3. 积分兑换商品需支付运费\n4. 兑换成功后积分实时扣除',
    categories: const [
      PointsCategory(id: 'all', label: '全部', iconUrl: ''),
      PointsCategory(id: 'local', label: '本地服务', iconUrl: ''),
      PointsCategory(id: 'coupon', label: '充值卡券', iconUrl: ''),
      PointsCategory(id: 'media', label: '影视会员', iconUrl: ''),
      PointsCategory(id: 'sports', label: '运动户外', iconUrl: ''),
    ],
    hotProducts: [
      const PointsProduct(
        id: 'h1',
        imageUrl: 'assets/images/product/product1.jpg',
        name: '专供青稞酒特别版 本42度500ml',
        points: 1000,
        stock: 500,
        salesCount: 123,
        tag: '热门',
        type: PointsProductType.physical,
      ),
      const PointsProduct(
        id: 'h2',
        imageUrl: 'assets/images/product/product1.jpg',
        name: '专供青稞酒特别版 本42度500ml',
        points: 1000,
        stock: 200,
        salesCount: 456,
        tag: '爆款',
        type: PointsProductType.physical,
      ),
      const PointsProduct(
        id: 'h3',
        imageUrl: 'assets/images/product/product1.jpg',
        name: '专供青稞酒特别版 本42度500ml',
        points: 1000,
        stock: 150,
        salesCount: 88,
        tag: '新品',
        type: PointsProductType.physical,
      ),
    ],
    redeemableGroups: [
      PointsRedeemGroup(
        rangeLabel: '0-1000',
        products: [
          const PointsProduct(
            id: 'r1',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '专供青稞酒特别版 本42度500ml',
            points: 1000,
            stock: 500,
            salesCount: 123,
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'r2',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '满100减20 优惠券',
            points: 500,
            stock: 999,
            salesCount: 888,
            type: PointsProductType.virtual,
          ),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '1000-5000',
        products: [
          const PointsProduct(
            id: 'r3',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '青藏特产牛肉干 100g',
            points: 2800,
            stock: 200,
            salesCount: 345,
            tag: '特产',
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'r4',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '高原枸杞 特级 250g',
            points: 3800,
            stock: 150,
            salesCount: 234,
            tag: '特产',
            type: PointsProductType.physical,
          ),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '5000-10000',
        products: [
          const PointsProduct(
            id: 'r5',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '天佑德青稞酒 经典款 500ml',
            points: 5800,
            originalPoints: 6800,
            stock: 100,
            salesCount: 567,
            tag: '热门',
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'r6',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '首单包邮 权益卡',
            points: 5000,
            stock: 500,
            salesCount: 123,
            type: PointsProductType.service,
          ),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '10000-20000',
        products: [
          const PointsProduct(
            id: 'r7',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '天佑德礼盒装 500ml×2',
            points: 12800,
            originalPoints: 15800,
            stock: 50,
            salesCount: 67,
            tag: '礼盒',
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'r8',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '视频会员年卡',
            points: 15000,
            stock: 300,
            salesCount: 89,
            type: PointsProductType.virtual,
          ),
        ],
      ),
      PointsRedeemGroup(
        rangeLabel: '20000以上',
        products: [
          const PointsProduct(
            id: 'r9',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '高端青稞酒礼盒 500ml×6',
            points: 28800,
            originalPoints: 35800,
            stock: 20,
            salesCount: 12,
            tag: '旗舰',
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'r10',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '智能家居套装',
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
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(_mockHomeData);
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({
    required int page,
    required int pageSize,
    String? categoryId,
    String? keyword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

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
    final List<PointsProduct> paginated = start < products.length
        ? products.sublist(start, end.clamp(0, products.length))
        : [];

    final result = PointsMallHomeData(
      bannerUrl: _mockHomeData.bannerUrl,
      bannerUrls: _mockHomeData.bannerUrls,
      currentPoints: _mockHomeData.currentPoints,
      expiringPoints: _mockHomeData.expiringPoints,
      expiryDate: _mockHomeData.expiryDate,
      rulesText: _mockHomeData.rulesText,
      categories: _mockHomeData.categories,
      hotProducts: paginated,
      redeemableGroups: _mockHomeData.redeemableGroups,
    );

    return ApiResponse.success(result);
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
        description: '这是${product.name}的详细描述，品质优良，值得兑换。',
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
        productName: '专供青稞酒特别版 本42度500ml',
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

/// MockPointsRepository Provider - 开发环境使用
final mockPointsRepositoryProvider = Provider<PointsRepository>((ref) => MockPointsDataSource());