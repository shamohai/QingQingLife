import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/presentation/paging/paging_controller_mixin.dart';
import '../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城商品分页 Notifier
class PointsMallProductListNotifier extends PagingNotifier<PointsProduct> {
  @override
  int get pageSize => 10;

  @override
  Future<PagingResult<PointsProduct>> fetchPage(int page, int pageSize) async {
    final repository = ref.read(pointsRepositoryProvider);
    final response = await repository.getProducts(page: page, pageSize: pageSize);
    if (!response.success || response.data == null) {
      throw Exception(response.message ?? '获取积分商品失败');
    }
    final result = response.data!;
    return PagingResult<PointsProduct>(
      items: result.recommendedProducts,
      hasMore: result.recommendedProducts.length >= pageSize,
      totalItems: result.recommendedProducts.length,
      totalPages: (result.recommendedProducts.length / pageSize).ceil(),
    );
  }
}

final pointsMallProductListProvider =
    NotifierProvider.autoDispose<PointsMallProductListNotifier, PagingData<PointsProduct>>(
  PointsMallProductListNotifier.new,
);

/// 积分商城首页静态数据 Provider
final pointsMallStaticDataProvider = FutureProvider<PointsMallStaticData>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getPointsMallHome();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取积分商城数据失败');
  }
  final data = response.data!;
  return PointsMallStaticData(
    bannerUrl: data.bannerUrl,
    currentPoints: data.currentPoints,
    expiringPoints: data.expiringPoints,
    expiryDate: data.expiryDate,
    rulesText: data.rulesText,
    categories: data.categories,
  );
});

/// 积分商城静态数据（不含分页商品列表）
class PointsMallStaticData {
  final String bannerUrl;
  final int currentPoints;
  final int expiringPoints;
  final DateTime expiryDate;
  final String rulesText;
  final List<PointsCategory> categories;

  const PointsMallStaticData({
    required this.bannerUrl,
    required this.currentPoints,
    required this.expiringPoints,
    required this.expiryDate,
    required this.rulesText,
    required this.categories,
  });
}
