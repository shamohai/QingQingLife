import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qingqinglife/app/router/route_names.dart';
import 'package:qingqinglife/core/location/device_location_service.dart';
import 'package:qingqinglife/core/location/location_gate.dart';

/// 线上活动打开器，统一处理活动 URL 导航（支持 activityType 动态注入）。
abstract final class ActivityOpener {
  /// 需要定位才能进入的微盟活动类型（与 ActivityWebViewPage 的判断保持一致）。
  static const Set<String> _locationActivityTypes = {'drinkmapactivity', 'drinkrankactivity'};

  static Future<void> open({
    required BuildContext context,
    required WidgetRef ref,
    required String actionUrl,
    required String activityId, // e.g. 'drinkmapactivity', 'drinkrankactivity', etc.
  }) async {
    final path = actionUrl.trim();
    if (path.isEmpty) return;

    final baseUri = Uri.tryParse(path);
    if (baseUri == null || (baseUri.scheme != 'http' && baseUri.scheme != 'https') || baseUri.host.isEmpty) return;

    if (!context.mounted) return;

    final activityType = activityId.trim();
    // 定位门禁：未开启定位时弹窗引导，取消则不进入活动。
    if (_locationActivityTypes.contains(activityType.toLowerCase())) {
      final ready = await LocationGate.ensure(context: context, service: ref.read(deviceLocationServiceProvider));
      if (!ready || !context.mounted) return;
    }

    final queryParams = <String, String>{'url': baseUri.toString(), if (activityType.isNotEmpty) 'activityType': activityType};
    final route = Uri(path: RouteNames.activityWebView, queryParameters: queryParams);
    context.push(route.toString());
  }
}
