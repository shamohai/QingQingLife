import 'dart:convert';

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
/// 返回商品详情图片 URL 列表，用于渲染商品详情视觉区
final productDetailImagesProvider = FutureProvider.family.autoDispose<List<String>, String>((ref, productId) async {
  final productIdValue = int.tryParse(productId);
  if (productIdValue == null || productIdValue <= 0) {
    return const [];
  }
  final response = await ref
      .read(apiClientProvider)
      .post<List<String>>(
        '/api/product/getproductdetailimg',
        data: <String, dynamic>{'pid': productIdValue},
        fromJson: (dynamic json) => parseProductDetailImages(json),
      );
  if (!response.success || response.data == null) {
    return const [];
  }
  return response.data!;
});

/// 解析 /api/product/getproductdetailimg 接口返回的图片列表
List<String> parseProductDetailImages(dynamic json) {
  if (json == null) return const [];
  List<dynamic> rawList = [];

  if (json is List) {
    rawList = json;
  } else if (json is Map) {
    final possibleKeys = ['images', 'imglist', 'detailimg', 'productdetailimg', 'list', 'data', 'urls', 'img_list'];
    for (final key in possibleKeys) {
      if (json[key] is List) {
        rawList = json[key] as List;
        break;
      }
    }
  } else if (json is String) {
    final trimmed = json.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) rawList = decoded;
      } catch (_) {}
    } else if (trimmed.contains(',')) {
      rawList = trimmed.split(',');
    } else if (trimmed.isNotEmpty) {
      rawList = [trimmed];
    }
  }

  final result = <String>[];
  for (final item in rawList) {
    if (item == null) continue;
    String url = '';
    if (item is Map) {
      url = (item['url'] ?? item['imgurl'] ?? item['image'] ?? item['src'] ?? '').toString();
    } else {
      url = item.toString();
    }
    url = url.trim().replaceAll('&amp;', '&');
    if (url.isEmpty) continue;
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    result.add(url);
  }
  return result;
}

