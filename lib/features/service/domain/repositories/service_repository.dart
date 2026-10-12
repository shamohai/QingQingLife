import '../../../../core/network/api_response.dart';
import '../models/share_cart_template_model.dart';
import '../models/share_cart_template_detail_model.dart';
import '../models/share_cart_product_model.dart';
import '../models/share_cart_candidate_model.dart';

/// 服务中心仓库接口
abstract class ServiceRepository {
  /// 获取购酒享服务模板列表
  Future<ApiResponse<List<ShareCartTemplate>>> getShareCartTemplateList();

  /// 获取购酒享服务模板详情
  Future<ApiResponse<ShareCartTemplateDetail>> getShareCartTemplateDetail(int templateId);

  /// 创建权益购物车（当 cartId 为空时调用）
  /// 请求 body：{"templateid": templateId}
  /// 响应：{"sharecartid": int}
  Future<ApiResponse<int>> createShareCart(int templateId);

  /// 获取购物车中的商品列表
  /// 请求 body：{"sharecartid": shareCartId, "listtype": 1}
  Future<ApiResponse<ShareCartProductList>> getShareCartProductList(int shareCartId);

  /// 获取继续加购候选商品列表（支持分页）
  /// 请求 body：{"sharecartid": shareCartId, "pageindex": pageIndex, "pagesize": pageSize}
  Future<ApiResponse<CandidateProductList>> getCandidateProductList(int shareCartId, int pageIndex, int pageSize);
}
