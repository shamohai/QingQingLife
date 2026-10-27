import '../../../../core/network/api_response.dart';
import '../../../points_mall/data/models/points_mall_home_data.dart';
import '../../../points_mall/data/models/sign_in_result.dart';
import '../../../points_mall/data/models/service_product_detail_model.dart';
import '../../../points_mall/data/models/get_recommend_product_list_model.dart';
import '../../../points_mall/data/models/get_credit_product_list_model.dart';
import '../../../points_mall/data/models/credit_product_category_model.dart';
import '../../../points_mall/data/models/pre_credit_order_info_model.dart';
import '../../../points_mall/data/models/points_submit_order_models.dart';

/// 积分商城仓库接口
abstract class PointsRepository {
  /// 获取积分商城首页数据
  Future<ApiResponse<PointsMallHomeData>> getPointsMallHome();

  /// 获取积分商品列表（分页）
  Future<ApiResponse<PointsMallHomeData>> getProducts({required int page, required int pageSize, String? categoryId, String? keyword});

  /// 获取积分商品详情
  Future<ApiResponse<PointsProductDetail>> getProductDetail(String productId);

  /// 获取积分商城服务商品详情
  Future<ApiResponse<ServiceProductDetail>> getServiceProductDetail(String productId);

  /// 积分兑换下单
  Future<ApiResponse<PointsExchangeResult>> exchangePointsProduct({
    required String productId,
    required int quantity,
    required String addressId,
    String? remark,
  });

  /// 获取兑换记录（分页）
  Future<ApiResponse<List<PointsExchangeRecord>>> getExchangeRecords({required int page, required int pageSize, ExchangeStatus? status});

  /// 获取签到结果
  Future<ApiResponse<SignInResult>> signIn();

  /// 获取签到日历
  Future<ApiResponse<SignInCalendarResult>> getSignInCalendar({required int year, required int month});

  /// 获取积分规则
  Future<ApiResponse<String>> getPointsRule();

  /// 获取推荐商品列表（推荐位接口，positioncode 区分不同位置）
  /// 接口：POST /api/product/getrecommendproductlist
  Future<ApiResponse<List<CreditMallProduct>>> getRecommendProductList({required String positionCode});

  /// 获取积分商城商品分类列表
  /// 接口：POST /api/product/app/getcreditproductcategory
  Future<ApiResponse<CreditProductCategoryData>> getCreditProductCategory();

  /// 获取青稞粒商品列表（分页，支持积分段和分类筛选）
  /// 接口：POST /api/product/getcreditproductlist
  Future<ApiResponse<CreditProductListData>> getCreditProductList({
    required int page,
    required int pageSize,
    int? minIntegral,
    int? maxIntegral,
    bool? exchangeable,
    int? categoryId,
    int? sort,
    bool? asc,
  });

  /// 获取预下单积分订单信息
  /// 接口：POST /api/order/dealprecreditorderinfo
  Future<ApiResponse<PreCreditOrderInfoModel>> getPreCreditOrderInfo({
    required int userServiceId,
    required String productId,
    required int quantity,
  });

  /// 提交青稞粒/自营积分订单 (OrderType == 2)
  /// 接口：POST /api/order/submitcreditorder
  Future<ApiResponse<SubmitCreditOrderResp>> submitCreditOrder(SubmitCreditOrderReq req);

  /// 提交服务券兑换订单 (OrderType == 23)
  /// 接口：POST /api/order/v2/submitservicecouponintegralorder
  Future<ApiResponse<SubmitServiceCouponIntegralOrderResp>> submitServiceCouponIntegralOrder(SubmitServiceCouponIntegralOrderReq req);

  /// 提交百礼汇第三方积分订单 (OrderType == 25)
  /// 接口：POST /api/order/submitbailihuiorder
  Future<ApiResponse<SubmitBaiLiHuiOrderResp>> submitBaiLiHuiOrder(SubmitBaiLiHuiOrderReq req);
}

/// 积分商品详情
class PointsProductDetail {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int points;
  final int? stock;
  final List<PointsProductSku> skus;
  final String rulesText;
  final PointsProductType type;
  final int maxExchangePerUser;
  final int? exchangedCount;

  const PointsProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.points,
    this.stock,
    required this.skus,
    required this.rulesText,
    required this.type,
    required this.maxExchangePerUser,
    this.exchangedCount,
  });
}

/// 积分商品 SKU
class PointsProductSku {
  final String id;
  final String name;
  final int points;
  final int stock;
  final Map<String, String> attributes;

  const PointsProductSku({required this.id, required this.name, required this.points, required this.stock, required this.attributes});
}

/// 兑换下单结果
class PointsExchangeResult {
  final String orderId;
  final String orderNo;
  final int pointsDeducted;
  final ExchangeStatus status;

  const PointsExchangeResult({required this.orderId, required this.orderNo, required this.pointsDeducted, this.status = ExchangeStatus.pending});
}

/// 兑换记录
class PointsExchangeRecord {
  final String id;
  final String exchangeNo;
  final String productId;
  final String productName;
  final String productImageUrl;
  final int pointsDeducted;
  final int quantity;
  final ExchangeStatus status;
  final String? statusText;
  final DateTime createTime;
  final DateTime? shipTime;
  final DateTime? receiveTime;
  final String? logisticsCompany;
  final String? logisticsNo;

  const PointsExchangeRecord({
    required this.id,
    required this.exchangeNo,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.pointsDeducted,
    required this.quantity,
    required this.status,
    this.statusText,
    required this.createTime,
    this.shipTime,
    this.receiveTime,
    this.logisticsCompany,
    this.logisticsNo,
  });
}

enum ExchangeStatus {
  pending('待发货'),
  shipped('待收货'),
  completed('已完成'),
  cancelled('已取消');

  const ExchangeStatus(this.label);
  final String label;
}
