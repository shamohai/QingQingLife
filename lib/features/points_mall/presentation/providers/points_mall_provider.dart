import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../points/domain/repositories/points_repository.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../features/points_mall/data/models/points_mall_home_data.dart';

/// 积分商城数据异步 Provider - 通过 Repository 获取数据
final pointsMallDataProvider = FutureProvider<PointsMallHomeData>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getPointsMallHome();

  if (!response.success || response.data == null) {
    throw Exception(response.message ?? '获取积分商城数据失败');
  }

  return response.data!;
});
