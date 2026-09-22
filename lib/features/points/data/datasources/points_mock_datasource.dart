import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/points_repository.dart';
import '../../../../core/network/api_response.dart';
import '../../../points_mall/data/models/points_mall_home_data.dart';
import '../../../points_mall/data/models/sign_in_result.dart';
import '../../../points_mall/data/models/service_product_detail_model.dart';

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
          const PointsCategory(id: 'all', label: '全部分类', iconUrl: ''),
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
          const PointsProduct(
            id: 'pp_service_1',
            imageUrl: 'assets/images/product/product1.jpg',
            name: '本地家政保洁服务卡（尊享3小时）',
            points: 2500,
            stock: 99,
            salesCount: 88,
            type: PointsProductType.service,
          ),
        ],
        redeemableGroups: [
          PointsRedeemGroup(
            rangeLabel: '1000-2000',
            products: [
              const PointsProduct(
                id: 'pp4',
                imageUrl: 'assets/images/product/product2.jpg',
                name: '积分专享饼干积分专享饼干积分专享饼干积分专享饼干',
                points: 1200,
                stock: 99,
                salesCount: 100,
                type: PointsProductType.physical,
              ),
              const PointsProduct(
                id: 'pp_service_2',
                imageUrl: 'assets/images/product/product2.jpg',
                name: '青海湖一日游电子导览门票服务',
                points: 1800,
                stock: 200,
                salesCount: 150,
                type: PointsProductType.service,
              ),
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
      // 2026年10月记录
      PointsExchangeRecord(
        id: 'exc_10_1',
        exchangeNo: 'EXC20261001001',
        productId: 'pp1',
        productName: '兑换优酷会员月卡',
        productImageUrl: 'assets/images/product/product1.jpg',
        pointsDeducted: -1000,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 10, 1, 12, 1, 0),
      ),
      PointsExchangeRecord(
        id: 'exc_10_2',
        exchangeNo: 'EXC20261001002',
        productId: '',
        productName: '会员签到赠送',
        productImageUrl: '',
        pointsDeducted: 10,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 10, 1, 12, 1, 0),
      ),
      PointsExchangeRecord(
        id: 'exc_10_3',
        exchangeNo: 'EXC20261001003',
        productId: '',
        productName: '会员注册赠送',
        productImageUrl: '',
        pointsDeducted: 1000,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 10, 1, 10, 0, 0),
      ),
      // 2026年9月记录
      PointsExchangeRecord(
        id: 'exc_9_1',
        exchangeNo: 'EXC20260915001',
        productId: 'pp2',
        productName: '兑换青海牛肉干',
        productImageUrl: 'assets/images/product/product2.jpg',
        pointsDeducted: -1500,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 9, 15, 14, 30, 0),
      ),
      PointsExchangeRecord(
        id: 'exc_9_2',
        exchangeNo: 'EXC20260915002',
        productId: '',
        productName: '会员签到赠送',
        productImageUrl: '',
        pointsDeducted: 10,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 9, 15, 8, 0, 0),
      ),
      // 2026年8月记录
      PointsExchangeRecord(
        id: 'exc_8_1',
        exchangeNo: 'EXC20260801001',
        productId: 'pp3',
        productName: '兑换有机菜籽油',
        productImageUrl: 'assets/images/product/product3.jpg',
        pointsDeducted: -3000,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 8, 1, 10, 0, 0),
      ),
      PointsExchangeRecord(
        id: 'exc_8_2',
        exchangeNo: 'EXC20260801002',
        productId: '',
        productName: '会员签到赠送',
        productImageUrl: '',
        pointsDeducted: 10,
        quantity: 1,
        status: ExchangeStatus.completed,
        createTime: DateTime(2026, 8, 1, 8, 0, 0),
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
  Future<ApiResponse<ServiceProductDetail>> getServiceProductDetail(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(ServiceProductDetail.mock);
  }

  @override
  Future<ApiResponse<String>> getPointsRule() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ApiResponse.success(
      '为规范青轻生活馆APP（以下简称“本APP”）积分商城运营，保障全体用户合法权益，明确积分获取、使用、兑换、失效等相关规则，营造公平、有序的平台消费体验，特制定本积分规则。本规则适用于所有注册并使用本APP积分商城功能的用户，开通积分功能即视为自愿认可并遵守本规则全部条款。 一、积分基本定义 1. 青轻积分是本APP专属虚拟权益，仅可在青轻生活馆APP积分商城内使用，为用户专属消费兑换凭证，不支持提现、转账、售卖、折现、透支，不可兑换现金、不找零、不开发票，仅限本人账户使用，严禁跨账户转移、合并积分。 2. 积分分为累积积分与可用积分：累积积分是用户历史累计获得的全部积分总和，可作为用户平台活跃度、会员等级评定依据；可用积分是扣除已兑换、冻结、失效积分后，可正常用于商城兑换、权益抵扣的有效积分，日常消费兑换仅扣除可用积分。 二、积分获取规则 （一）新手专属积分 2. 新手完善资料：新用户完成头像、昵称、收货地址等基础资料完善，额外领取50积分，一次性领取。 1. 每日签到：用户每日登录APP完成签到，可领取5-15随机积分，连续签到可累计递增积分，断签重置基础积分额度，每日仅限领取1次。 3. 互动任务：参与平台日常问卷、好物评价、话题互动等轻任务，根据任务难度可获取10-30积分/次，每日任务积分设有上限。 1. 用户在本APP商城、生活馆板块消费，按实际支付金额累积积分，常规比例为每实付1元累积1积分，积分四舍五入计算，运费、优惠券抵扣金额、退款金额不计入积分累积基数。 3. 订单支付成功后积分实时到账，若订单后续发生退款、取消、售后退货，平台将扣除对应已发放积分，积分不足时可抵扣现金或冻结后续积分权益。',
    );
  }
}

/// MockPointsRepository Provider - 开发环境使用
final mockPointsRepositoryProvider = Provider<PointsRepository>((ref) => MockPointsDataSource());
