import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/points_repository.dart';

/// 积分规则页面数据 Provider
///
/// 从 [PointsRepository.getPointsRule] 获取规则文本。
/// 开发/测试环境由 [MockPointsDataSource] 提供静态内容。
final pointsRulesProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getPointsRule();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});
