import '../../../../core/network/api_response.dart';
import '../models/share_cart_template_model.dart';

/// 服务中心仓库接口
abstract class ServiceRepository {
  /// 获取购酒享服务模板列表
  Future<ApiResponse<List<ShareCartTemplate>>> getShareCartTemplateList();
}
