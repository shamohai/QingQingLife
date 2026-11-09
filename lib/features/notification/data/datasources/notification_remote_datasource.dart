import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/providers.dart';
import '../../domain/models/notification_models.dart';
import '../../domain/repositories/notification_repository.dart';

/// 通知中心远程数据源
///
/// 接口文档（公共模块）：
///   - POST /api/common/app/getnotificationtypestat
///   - POST /api/common/app/getmynotificationlist
///   - POST /api/common/app/marknotificationasread
///
/// 三个接口的 authtoken 与 meta（devid / version / channel / phonemodel / platform）
/// 均由 AuthInterceptor + EncryptInterceptor 统一注入，此处只传业务字段。
class NotificationRemoteDataSource implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  @override
  Future<ApiResponse<List<NotificationTypeStat>>> getTypeStats() async {
    return _apiClient.post<List<NotificationTypeStat>>(
      '/api/common/app/getnotificationtypestat',
      data: <String, dynamic>{},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        final listJson = source['list'] as List<dynamic>? ?? const <dynamic>[];
        return listJson.map((e) => NotificationTypeStat.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// 获取我的通知列表
  ///
  /// [typeValue] 为接口下发的原始 type 数值（来自类型统计的 type 字段）；
  /// null 表示全部类型（接口约定 null 或 -1 表示全部，此处传 -1）。
  /// [pageIndex] 从 1 开始，[pageSize] 不传时后端默认 10。
  @override
  Future<ApiResponse<List<NotificationMessage>>> getMessages({int? typeValue, int pageIndex = 1, int pageSize = 20}) async {
    return _apiClient.post<List<NotificationMessage>>(
      '/api/common/app/getmynotificationlist',
      data: <String, dynamic>{'notificationtype': typeValue ?? -1, 'pageindex': pageIndex, 'pagesize': pageSize},
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        final listJson = source['list'] as List<dynamic>? ?? const <dynamic>[];
        return listJson.map((e) => NotificationMessage.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<ApiResponse<int>> markAsRead({int? notificationId, int? typeValue}) async {
    // 接口约定：指定 notificationid 时只标记该条；未指定 id 时才按 type 标记整类。
    // 未使用的字段不传，避免后端把 0 / null 当作有效筛选条件。
    final data = <String, dynamic>{};
    if (notificationId != null) {
      data['notificationid'] = notificationId;
    } else if (typeValue != null) {
      data['type'] = typeValue;
    }

    return _apiClient.post<int>(
      '/api/common/app/marknotificationasread',
      data: data,
      fromJson: (dynamic json) {
        final source = json as Map<String, dynamic>? ?? const <String, dynamic>{};
        return (source['effectcount'] as num?)?.toInt() ?? 0;
      },
    );
  }
}

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.read(apiClientProvider));
});
