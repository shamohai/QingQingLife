import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/update_info.dart';
import '../../network/providers.dart';
import '../../../app/config/app_config.dart';
import '../shiply/shiply_initializer.dart';

enum VersionCheckState { initial, checking, checked, error }

class VersionCheckNotifier extends Notifier<({
  VersionCheckState state,
  UpdateInfo? info,
  String? error,
})> {
  @override
  ({ VersionCheckState state, UpdateInfo? info, String? error }) build() {
    return (state: VersionCheckState.initial, info: null, error: null);
  }

  Future<void> check() async {
    state = (state: VersionCheckState.checking, info: state.info, error: state.error);

    final shiplyFuture = ShiplyInitializer.initialize(
      appVersion: AppConfig.appVersionName,
      appVersionCode: AppConfig.appVersionCode,
    );

    late UpdateInfo info;
    try {
      final result = await ref.read(apiClientProvider).get<Map<String, dynamic>>(
        '${AppConfig.baseUrl}/api/app/version/check',
        queryParameters: {
          'platform': _getPlatform(),
          'versionCode': AppConfig.appVersionCode,
          'versionName': AppConfig.appVersionName,
        },
      );
      info = result.success && result.data != null
          ? UpdateInfo.fromJson(result.data!)
          : UpdateInfo(
              versionCode: AppConfig.appVersionCode,
              versionName: AppConfig.appVersionName,
              updateContent: '',
            );
    } catch (e) {
      info = UpdateInfo(
        versionCode: AppConfig.appVersionCode,
        versionName: AppConfig.appVersionName,
        updateContent: '',
      );
    }

    await shiplyFuture;
    state = (state: VersionCheckState.checked, info: info, error: null);
  }

  String _getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return 'android';
      case TargetPlatform.iOS: return 'ios';
      default: return 'unknown';
    }
  }
}

final versionCheckProvider =
    NotifierProvider<VersionCheckNotifier, ({
      VersionCheckState state,
      UpdateInfo? info,
      String? error,
    })>(() => VersionCheckNotifier());
