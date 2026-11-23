import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/config/app_config.dart';
import '../../network/providers.dart';
import '../models/app_update_info.dart';
import '../services/check_update_client.dart';

/// 今日不再提醒：记录当天日期（yyyy-MM-dd），当天不再弹出非强制升级
const String appUpdateDismissedDateKey = 'app_update_dismissed_date';

/// 当天日期字符串，用于「今日不再提醒」判断
String todayDateKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// 启动时检查原生 apk 新版本（CheckUpdate 接口的 `appversion` 节点）
///
/// 规则：
/// - `appversion` 为空（纯热更新）：返回 null，不弹窗；热更新资源由 bootstrap 静默下载。
/// - 非强制升级：当天勾选过「今日不再提醒」则返回 null，次日恢复提醒。
/// - 强制升级：每次启动都返回（不可取消，直到安装新版本）。
///
/// 请求体只包含本地热更新版本号 `hotfixversion`，公共 meta 由 EncryptInterceptor 注入。
/// 失败时静默返回 null，不阻塞主流程。
final appUpdateProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final localBuildNumber = int.tryParse(packageInfo.buildNumber) ?? AppConfig.appVersionCode;
    final storage = ref.read(localStorageProvider);
    final data = await CheckUpdateClient.fetch(ref.read(apiClientProvider), storage);
    if (data == null) return null;

    final info = AppUpdateInfo.tryParse(data);
    if (info == null || info.buildNumber <= localBuildNumber) return null;

    if (!info.isForceUpdate) {
      final dismissedDate = await storage.getString(appUpdateDismissedDateKey) ?? '';
      if (dismissedDate == todayDateKey()) return null;
    }
    return info;
  } catch (_) {
    return null;
  }
});
