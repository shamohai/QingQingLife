import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/providers.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/models/share_cart_template_model.dart';

/// 服务中心远程数据源
class ServiceRemoteDataSource implements ServiceRepository {
  final ApiClient apiClient;

  ServiceRemoteDataSource({required this.apiClient});

  @override
  Future<ApiResponse<List<ShareCartTemplate>>> getShareCartTemplateList() async {
    return apiClient.post<List<ShareCartTemplate>>(
      '/api/groupMall/shareCart/gettemplatelist',
      data: <String, dynamic>{},
      fromJson: (dynamic json) {
        final listJson = json['list'] as List<dynamic>? ?? [];
        return listJson.map((e) => ShareCartTemplate.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiClient: ref.read(apiClientProvider));
});
