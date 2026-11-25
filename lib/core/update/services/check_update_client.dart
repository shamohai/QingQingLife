import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../../network/api_client.dart';
import '../../network/api_response.dart';
import '../../storage/local_storage.dart';

/// CheckUpdate 接口的统一请求入口（同一次启动只发起一次请求，结果在本次进程内共享）
///
/// 请求体只包含本地热更新版本号 `hotfixversion`，公共 meta 与 authtoken 由拦截器注入。
/// 弹窗（apk 升级）与热更新（资源下载）都从这里取同一份响应。
class CheckUpdateClient {
  CheckUpdateClient._();

  static const String apiPath = '/api/sys/app/checkupdate';
  static const String hotfixVersionKey = 'hot_update_hotfix_version';

  static Future<Map<String, dynamic>?>? _pending;

  /// 获取 CheckUpdate 响应；失败时返回 null
  static Future<Map<String, dynamic>?> fetch(ApiClient apiClient, LocalStorage storage) {
    return _pending ??= _request(apiClient, storage);
  }

  static Future<Map<String, dynamic>?> _request(ApiClient apiClient, LocalStorage storage) async {
    try {
      final localHotfixVersion = int.tryParse(await storage.getString(hotfixVersionKey) ?? '') ?? 0;
      final ApiResponse<Map<String, dynamic>> response = await apiClient.post<Map<String, dynamic>>(
        apiPath,
        data: {'hotfixversion': localHotfixVersion},
        fromJson: (data) => Map<String, dynamic>.from(data as Map),
        options: Options(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)),
      );
      if (!response.success) {
        AppLogger.warning('CheckUpdate 返回失败: ${response.message}', module: 'check_update', data: {'code': response.code});
        return null;
      }
      return response.dataOrNull;
    } catch (e) {
      AppLogger.warning('CheckUpdate 请求异常', module: 'check_update', error: e);
      return null;
    }
  }
}
