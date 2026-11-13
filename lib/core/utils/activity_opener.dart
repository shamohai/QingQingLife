import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qingqinglife/app/router/route_names.dart';

/// 线上活动打开器，统一处理活动 URL 导航（支持 activityType 动态注入）。
abstract final class ActivityOpener {
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

    final queryParams = <String, String>{
      'url': baseUri.toString(),
      if (activityId.trim().isNotEmpty) 'activityType': activityId.trim(),
    };
    final route = Uri(path: RouteNames.activityWebView, queryParameters: queryParams);
    context.push(route.toString());
  }
}
