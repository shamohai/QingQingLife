import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/points_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../points_mall/data/models/points_mall_home_data.dart';
import '../../../points_mall/data/models/sign_in_result.dart';

/// Mock 积分商城数据源 - 开发/测试环境使用
class MockPointsDataSource implements PointsRepository {
  @override
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ApiResponse.success(
      PointsMallHomeData(
        bannerUrl: 'assets/images/points/banner.jpg',
        bannerUrls: const ['assets/images/points/banner.jpg', 'assets/images/points/banner.jpg'],
        currentPoints: 3580,
        expiringPoints: 800,
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        rulesText: '积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月，到期前30天短信提醒。',
        categories: [
          const PointsCategory(id: 'all', label: '全部', iconUrl: ''),
          const PointsCategory(id: 'physical', label: '实物商品', iconUrl: ''),
          const PointsCategory(id: 'virtual', label: '虚拟卡券', iconUrl: ''),
          const PointsCategory(id: 'service', label: '本地服务', iconUrl: ''),
        ],
        hotProducts: [
          const PointsProduct(
            id: 'pp1',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '天佑德青稞酒 500ml',
            points: 2000,
            stock: 56,
            salesCount: 1234,
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'pp2',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '青海牛肉干 100g',
            points: 1500,
            stock: 128,
            salesCount: 2345,
            type: PointsProductType.physical,
          ),
          const PointsProduct(
            id: 'pp3',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '有机菜籽油 5L',
            points: 3000,
            stock: 32,
            salesCount: 567,
            type: PointsProductType.physical,
          ),
        ],
        redeemableGroups: [
          PointsRedeemGroup(
            rangeLabel: '1000-2000',
            products: [
              const PointsProduct(
                id: 'pp4',
                imageUrl: 'assets/images/product/product2.jpg',
                name: '积分专享饼干',
                points: 1200,
                stock: 99,
                salesCount: 100,
                type: PointsProductType.physical,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword}) async {
    return getPointsMallHome();
  }

  @override
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      const PointsProductDetail(
        id: 'pp1',
        name: '天佑德青稞酒 500ml',
        description: '青海特产青稞酒',
        images: ['assets/images/product/product1.jpg'],
        points: 2000,
        stock: 56,
        skus: [],
        rulesText: '积分兑换规则',
        type: PointsProductType.physical,
        maxExchangePerUser: 2,
        exchangedCount: 100,
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
      PointsExchangeResult(orderId: 'order_$productId', orderNo: 'NO${DateTime.now().millisecondsSinceEpoch}', pointsDeducted: 2000 * quantity),
    );
  }

  @override
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({required int page, required int pageSize, ExchangeStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success([
      PointsExchangeRecord(
        id: 'exc1',
        exchangeNo: 'EXC20240101001',
        productId: 'pp1',
        productName: '天佑德青稞酒 500ml',
        productImageUrl: 'assets/images/product/product1.jpg',
        pointsDeducted: 2000,
        quantity: 1,
        status: ExchangeStatus.shipped,
        createTime: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<ApiResponse<SignInResult>> signIn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(
      const SignInResult(success: true, pointsEarned: 10, consecutiveDays: 1, isConsecutiveBonus: false, bonusPoints: 0, message: '签到成功'),
    );
  }

  @override
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(SignInCalendarResult(year: year, month: month, records: [], totalSignedDays: 0, consecutiveDays: 0));
  }

  @override
  Future<ApiResponse<String>> getPointsRule() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success('积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月。');
  }
}

/// MockPointsRepository Provider - 开发环境使用
final mockPointsRepositoryProvider = Provider<PointsRepository>((ref) => MockPointsDataSource());
