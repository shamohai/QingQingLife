/// 首页轮播图数据 Provider
///
/// 调用真实 API 获取轮播图列表，失败时降级为空列表。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/data/datasources/product_datasource.dart';
import '../models/carousel_model.dart';

/// 首页轮播图 Provider
///
/// type=1（CarouselType.appHome）对应小程序首页轮播图
final homeCarouselProvider = FutureProvider<List<CarouselBanner>>((ref) async {
  final dataSource = ref.read(productDataSourceProvider);
  final response = await dataSource.getCarouselList(type: CarouselType.appHome);
  if (!response.success || response.data == null) return [];
  return response.data!;
});
