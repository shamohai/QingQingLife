import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';

/// 旧版本地积分规则 Provider；积分规则现由后端 H5 提供。
@Deprecated('积分规则现由后端 H5 页面提供。')
final pointsRulesProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.read(pointsRepositoryProvider);
  final response = await repository.getPointsRule();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});
