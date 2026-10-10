import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/service_project_detail_model.dart';

/// 预约项目详情数据异步 Provider（family，按 projectId 加载）
///
/// autoDispose：页面销毁时自动释放。
/// 一期使用静态 mock 数据，后续对接真实 API 时替换为 Repository 调用。
final serviceProjectDetailProvider =
    FutureProvider.family.autoDispose<ServiceProjectDetail, String>((ref, projectId) async {
  return ServiceProjectDetail.mock(projectId);
});
