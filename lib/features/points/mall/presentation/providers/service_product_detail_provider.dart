import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/providers.dart';
import '../../data/models/service_product_detail_model.dart';

/// 服务商品详情异步 Provider（family：按 productId 加载）
///
/// autoDispose：页面销毁时自动释放，避免 navigate back 时异步重建触发 build scope 错误。
final serviceProductDetailProvider = FutureProvider.family.autoDispose<ServiceProductDetail, String>((ref, productId) async {
  final productIdValue = int.tryParse(productId);
  if (productIdValue == null || productIdValue <= 0) {
    throw ArgumentError.value(productId, 'productId', '必须是正整数');
  }
  final response = await ref
      .read(apiClientProvider)
      .post<ServiceProductDetail>(
        '/api/product/getproductinfo',
        data: <String, dynamic>{'pid': productIdValue},
        fromJson: (dynamic json) => ServiceProductDetail.fromJson(Map<String, dynamic>.from(json as Map), fallbackProductId: productIdValue),
      );
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  return response.data!;
});

/// 商品详情图片列表异步 Provider（family：按 productId 加载）
///
/// 对应 API：POST /api/product/getproductdetailimg
/// 响应：{"detailimg": [{"imgurl": "...", "width": 1, "height": 1}], "result": 0, "descr": null, "datatag": ""}
final productDetailImagesProvider = FutureProvider.family.autoDispose<List<String>, String>((ref, productId) async {
  final productIdValue = int.tryParse(productId);
  if (productIdValue == null || productIdValue <= 0) {
    throw ArgumentError.value(productId, 'productId', '必须是正整数');
  }
  final response = await ref
      .read(apiClientProvider)
      .post<List<String>>(
        '/api/product/getproductdetailimg',
        data: <String, dynamic>{'pid': productIdValue},
        fromJson: (dynamic json) => _parseDetailImageUrls(json),
      );
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  return response.data!;
});

/// 从 getproductdetailimg 响应中取出图片地址列表（忽略 width / height）
List<String> _parseDetailImageUrls(dynamic json) {
  final list = (json as Map)['detailimg'] as List<dynamic>? ?? const [];
  return list.map((item) => ((item as Map)['imgurl'] as String? ?? '').trim()).where((url) => url.isNotEmpty).toList();
}
