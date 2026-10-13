import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/update_info.dart';
import '../../network/providers.dart';
import '../../../app/config/app_config.dart';

enum VersionCheckState { initial, checking, checked, error }

class VersionCheckNotifier extends Notifier<({VersionCheckState state, UpdateInfo? info, String? error})> {
  @override
  ({VersionCheckState state, UpdateInfo? info, String? error}) build() {
    return (state: VersionCheckState.initial, info: null, error: null);
  }

  Future<void> check() async {
    // 避免重复检查
    if (state.state == VersionCheckState.checking) return;

    state = (state: VersionCheckState.checking, info: state.info, error: state.error);

    late UpdateInfo info;
    try {
      final result = await ref
          .read(apiClientProvider)
          .get<Map<String, dynamic>>(
            '${AppConfig.baseUrl}/api/app/version/check',
            queryParameters: {'platform': _getPlatform(), 'versionCode': AppConfig.appVersionCode, 'versionName': AppConfig.appVersionName},
            options: Options(
              // 短超时（3秒），避免真机弱网或无网络时长时间阻塞
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
          );
      info = result.success && result.data != null
          ? UpdateInfo.fromJson(result.data!)
          : UpdateInfo(versionCode: AppConfig.appVersionCode, versionName: AppConfig.appVersionName, updateContent: '');
    } catch (e) {
      // 网络异常时静默使用默认值，不阻塞主流程
      info = UpdateInfo(versionCode: AppConfig.appVersionCode, versionName: AppConfig.appVersionName, updateContent: '');
    }

    state = (state: VersionCheckState.checked, info: info, error: null);
  }

  String _getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }
}

final versionCheckProvider = NotifierProvider<VersionCheckNotifier, ({VersionCheckState state, UpdateInfo? info, String? error})>(() => VersionCheckNotifier());

/// 启动时自动触发版本检查的 Provider
/// 通过 Provider 初始化时自动执行 check()
final autoVersionCheckProvider = Provider<void>((ref) {
  // 延迟执行，避免阻塞首帧
  Future.microtask(() => ref.read(versionCheckProvider.notifier).check());
});
