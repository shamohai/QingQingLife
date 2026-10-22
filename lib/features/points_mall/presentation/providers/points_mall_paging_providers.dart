import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城商品分页 Notifier（支持分类过滤）
class PointsMallProductListNotifier extends PagingNotifier<PointsProduct> {
  String? _categoryId;

  void setCategoryId(String? categoryId) {
    _categoryId = categoryId;
  }

  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<PointsProduct>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(pointsRepositoryProvider);
    final response = await repository.getProducts(page: page, pageSize: pageSize, categoryId: _categoryId);
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    final result = response.data!;
    return PagingResult<PointsProduct>(
      items: result.hotProducts,
      hasMore: result.hotProducts.length >= pageSize,
      totalItems: result.hotProducts.length,
      totalPages: (result.hotProducts.length / pageSize).ceil(),
    );
  }
}

final pointsMallProductListProvider = NotifierProvider.autoDispose<PointsMallProductListNotifier, PagingData<PointsProduct>>(PointsMallProductListNotifier.new);

/// 热门商品（优先调用真实推荐位接口加载，失败/无数据时降级使用 Mock）
final pointsMallHotProductsProvider = FutureProvider<List<PointsProduct>>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  try {
    final response = await repository.getRecommendProductList(positionCode: 'APP_CREDITMALL');
    if (response.success && response.data != null && response.data!.isNotEmpty) {
      return response.data!.map((item) {
        return PointsProduct(
          id: item.productId.toString(),
          imageUrl: item.imgUrl,
          name: item.productName,
          points: item.creditPrice,
          commentCount: item.commentCount,
          tag: '热门',
          type: item.isService ? PointsProductType.service : PointsProductType.physical,
        );
      }).toList();
    }
  } catch (ex) {
    throw Exception(ex);
  }
  return [];
});

/// 积分商城首页静态数据 Provider
final pointsMallStaticDataProvider = FutureProvider<PointsMallStaticData>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getPointsMallHome();
  if (!response.success || response.data == null) {
    throw Exception(response.message);
  }
  final data = response.data!;
  return PointsMallStaticData(
    bannerUrls: data.bannerUrls,
    currentPoints: data.currentPoints,
    expiringPoints: data.expiringPoints,
    expiryDate: data.expiryDate,
    rulesText: data.rulesText,
    categories: data.categories,
    redeemableGroups: data.redeemableGroups,
  );
});

/// 积分商城静态数据（不含分页商品列表）
class PointsMallStaticData {
  final List<String> bannerUrls;
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final String rulesText;
  final List<PointsCategory> categories;
  final List<PointsRedeemGroup> redeemableGroups;

  const PointsMallStaticData({
    required this.bannerUrls,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    required this.rulesText,
    required this.categories,
    required this.redeemableGroups,
  });
}
