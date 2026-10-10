import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/share_cart_template_detail_model.dart';
import '../../data/datasources/service_remote_datasource.dart';

/// 购酒享服务模板详情 Provider（按模板 ID 加载）
///
/// 路由: /service/template/:id，进入方式：服务中心「购酒享服务」列表页点击跳转。
/// 数据来源: [ServiceRemoteDataSource]（需注入 apiClientProvider）。
final shareCartTemplateDetailProvider =
    AsyncNotifierProvider.family<ShareCartTemplateDetailNotifier, ShareCartTemplateDetail, int>(
      (templateId) => ShareCartTemplateDetailNotifier(templateId),
    );

class ShareCartTemplateDetailNotifier extends AsyncNotifier<ShareCartTemplateDetail> {
  final int _templateId;

  ShareCartTemplateDetailNotifier(this._templateId);

  @override
  Future<ShareCartTemplateDetail> build() async {
    final dataSource = ref.read(serviceRemoteDataSourceProvider);
    final response = await dataSource.getShareCartTemplateDetail(_templateId);
    return response.requireData;
  }
}
