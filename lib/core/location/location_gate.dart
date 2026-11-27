import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'device_location_service.dart';
import 'location_gate_dialog.dart';

/// 定位门禁：进入依赖定位的活动前调用。未就绪时弹窗引导用户开启定位，
/// 用户去系统设置后回到 App 自动重新检查，就绪后返回 true。
///
/// 弹窗提供「取消」按钮（审核要求：不强制用户开启定位），取消则返回 false，不进入活动。
abstract final class LocationGate {
  /// 返回 true 表示可以继续获取定位。
  static Future<bool> ensure({required BuildContext context, required DeviceLocationService service}) async {
    // Web debug 联调与真机逻辑保持一致的旁路，见 DeviceLocationService.getPosition。
    if (kIsWeb && kDebugMode) return true;
    if (await service.hasValidCache()) return true;

    // 是否已经调用过系统权限弹窗：系统框只能主动弹一次，之后引导去设置。
    var requestedOnce = false;
    while (true) {
      final failure = await service.checkReadiness();
      if (failure == null) return true;
      if (failure == LocationFailure.unavailable) return false;
      if (!context.mounted) return false;

      final content = _contentFor(failure, requestedOnce: requestedOnce);
      final confirmed = await showLocationGateDialog(context, content);
      if (confirmed != true || !context.mounted) return false;

      if (failure == LocationFailure.permissionDenied && !requestedOnce) {
        requestedOnce = true;
        await service.requestPermission();
        continue;
      }

      await service.openSettingsFor(failure);
      await _waitUntilResumed();
    }
  }

  static LocationGateDialogContent _contentFor(LocationFailure failure, {required bool requestedOnce}) {
    switch (failure) {
      case LocationFailure.serviceDisabled:
        return const LocationGateDialogContent(title: '开启定位服务', message: '线上活动需要获取您的位置信息，请开启手机定位服务后继续。', confirmText: '去开启', icon: Icons.location_on_outlined);
      case LocationFailure.permissionDenied when !requestedOnce:
        return const LocationGateDialogContent(title: '允许使用定位', message: '线上活动需要获取您的位置信息，用于匹配所在地区的活动内容。', confirmText: '去允许', icon: Icons.my_location_outlined);
      case LocationFailure.permissionDenied:
      case LocationFailure.permissionDeniedForever:
        return const LocationGateDialogContent(
          title: '需要定位权限',
          message: '定位权限未开启，请在系统设置中允许青轻生活使用定位权限后继续。',
          confirmText: '去设置',
          icon: Icons.location_off_outlined,
        );
      case LocationFailure.unavailable:
        return const LocationGateDialogContent(title: '无法获取定位', message: '请稍后重试。', confirmText: '确定', icon: Icons.error_outline);
    }
  }

  /// 等待用户从系统设置页返回前台（先进入后台，再回到前台）。
  /// 设置较长的兜底超时，避免设置页未能打开时一直挂起。
  static Future<void> _waitUntilResumed() async {
    final completer = Completer<void>();
    final observer = _ResumeObserver(completer);
    WidgetsBinding.instance.addObserver(observer);
    try {
      await completer.future.timeout(const Duration(minutes: 10), onTimeout: () {});
    } finally {
      WidgetsBinding.instance.removeObserver(observer);
    }
  }
}

class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver(this._completer);

  final Completer<void> _completer;
  bool _paused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _paused = true;
    if (state == AppLifecycleState.resumed && _paused && !_completer.isCompleted) {
      _completer.complete();
    }
  }
}
