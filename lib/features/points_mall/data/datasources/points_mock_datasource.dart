import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../data/models/points_mall_home_data.dart';
import '../../data/models/sign_in_result.dart';

/// Mock 积分商城数据源 - 开发/测试环境使用
class MockPointsDataSource implements PointsRepository {
  final _uuid = const Uuid();

  // 模拟数据
  static final _mockHomeData = PointsMallHomeData(
    bannerUrl: 'https://picsum.photos/750/200?random=99',
    currentPoints: 3580,
    expiringPoints: 200,
    expiryDate: DateTime(2025, 12, 31),
    rulesText: '1. 积分有效期为当年1月1日至次年12月31日\n2. 积分不可兑现、不可转让\n3. 积分兑换商品需支付运费\n4. 兑换成功后积分实时扣除',
    categories: const [
      PointsCategory(id: 'all', label: '全部', iconUrl: ''),
      PointsCategory(id: 'gift', label: '礼品兑换', iconUrl: ''),
      PointsCategory(id: 'coupon', label: '优惠券', iconUrl: ''),
      PointsCategory(id: 'service', label: '增值服务', iconUrl: ''),
    ],
    recommendedProducts: [
      const PointsProduct(
        id: 'p1',
        imageUrl: 'https://picsum.photos/300/300?random=80',
        name: '天佑德青稞酒 经典款 500ml',
        points: 5800,
        originalPoints: 6800,
        stock: 100,
        salesCount: 123,
        tag: '热门',
        type: PointsProductType.physical,
      ),
      const PointsProduct(
        id: 'p2',
        imageUrl: 'https://picsum.photos/300/300?random=81',
        name: '青藏特产牛肉干 100g',
        points: 2800,
        originalPoints: 3200,
        stock: 200,
        salesCount: 456,
        tag: '特产',
        type: PointsProductType.physical,
      ),
      const PointsProduct(
        id: 'p3',
        imageUrl: 'https://picsum.photos/300/300?random=82',
        name: '满100减20 优惠券',
        points: 500,
        originalPoints: null,
        stock: 999,
        salesCount: 888,
        tag: '优惠',
        type: PointsProductType.virtual,
      ),
      const PointsProduct(
        id: 'p4',
        imageUrl: 'https://picsum.photos/300/300?random=83',
        name: '首单包邮 权益卡',
        points: 1000,
        originalPoints: 1500,
        stock: 500,
        salesCount: 234,
        tag: '权益',
        type: PointsProductType.service,
      ),
      const PointsProduct(
        id: 'p5',
        imageUrl: 'https://picsum.photos/300/300?random=84',
        name: '天佑德礼盒装 500ml×2',
        points: 12800,
        originalPoints: 15800,
        stock: 50,
        salesCount: 67,
        tag: '礼盒',
        type: PointsProductType.physical,
      ),
      const PointsProduct(
        id: 'p6',
        imageUrl: 'https://picsum.photos/300/300?random=85',
        name: '高原枸杞 特级 250g',
        points: 3800,
        originalPoints: 4200,
        stock: 150,
        salesCount: 345,
        tag: '特产',
        type: PointsProductType.physical,
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

    var products = List<PointsProduct>.from(_mockHomeData.recommendedProducts);

    if (categoryId != null && categoryId != 'all') {
      if (categoryId == 'gift') {
        products = products.where((p) => p.type == PointsProductType.physical).toList();
      } else if (categoryId == 'coupon') {
        products = products.where((p) => p.type == PointsProductType.virtual).toList();
      } else if (categoryId == 'service') {
        products = products.where((p) => p.type == PointsProductType.service).toList();
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
      currentPoints: _mockHomeData.currentPoints,
      expiringPoints: _mockHomeData.expiringPoints,
      expiryDate: _mockHomeData.expiryDate,
      rulesText: _mockHomeData.rulesText,
      categories: _mockHomeData.categories,
      recommendedProducts: paginated,
    );

    return ApiResponse.success(result);
  }

  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final product = _mockHomeData.recommendedProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => _mockHomeData.recommendedProducts.first,
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
        productId: 'p1',
        productName: '天佑德青稞酒 经典款 500ml',
        productImageUrl: 'https://picsum.photos/300/300?random=80',
        pointsDeducted: 5800,
        quantity: 1,
        status: ExchangeStatus.completed,
        statusText: '已完成',
        createTime: DateTime.now().subtract(const Duration(days: 10)),
        shipTime: DateTime.now().subtract(const Duration(days: 8)),
        receiveTime: DateTime.now().subtract(const Duration(days: 5)),
        logisticsCompany: '顺丰速运',
        logisticsNo: 'SF1234567890',
      ),
      PointsExchangeRecord(
        id: 'r2',
        exchangeNo: 'EX20250101002',
        productId: 'p3',
        productName: '满100减20 优惠券',
        productImageUrl: 'https://picsum.photos/300/300?random=82',
        pointsDeducted: 500,
        quantity: 1,
        status: ExchangeStatus.completed,
        statusText: '已完成',
        createTime: DateTime.now().subtract(const Duration(days: 5)),
        shipTime: null,
        receiveTime: null,
        logisticsCompany: null,
        logisticsNo: null,
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
        records: [
          const SignInDayRecord(day: 1, isSigned: true, pointsEarned: 10, isToday: false),
          const SignInDayRecord(day: 2, isSigned: true, pointsEarned: 10, isToday: false),
        ], 
        totalSignedDays: 5, 
        consecutiveDays: 5
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
