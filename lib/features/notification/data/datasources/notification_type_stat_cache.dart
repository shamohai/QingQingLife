import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/models/notification_models.dart';

/// 通知类型统计本地缓存
///
/// 用于在类型统计接口返回前先行渲染顶部 tab 与列表卡片类型图标：
/// 接口首次成功后写入本地，下次进入页面先读缓存渲染，
/// 待接口返回后再刷新界面并更新缓存（stale-while-revalidate）。
///
/// 缓存规范：key（含版本号）+ 写入时间 + 过期时间（7 天）；
/// 无缓存 / 已过期 / 数据损坏时视为无缓存，不影响接口加载。
class NotificationTypeStatCache {
  /// 缓存 key（v1：结构变更时升级版本并废弃旧数据）
  static const String _key = 'notification_type_stat_cache_v1';

  /// 缓存有效期
  static const Duration _duration = Duration(days: 7);

  final LocalStorage _storage = LocalStorage();

  /// 读取未过期的缓存数据；无缓存 / 已过期 / 数据损坏时返回 null
  Future<List<NotificationTypeStat>?> read() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = (wrapper['ts'] as num?)?.toInt() ?? 0;
      final isExpired = DateTime.now().millisecondsSinceEpoch - savedAt > _duration.inMilliseconds;
      if (isExpired) return null;

      final list = wrapper['list'];
      if (list is! List) return null;
      return list.map((e) => NotificationTypeStat.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // 缓存内容损坏时按无缓存处理，等待接口刷新
      return null;
    }
  }

  /// 写入缓存（记录写入时间用于过期判断）
  Future<void> write(List<NotificationTypeStat> stats) async {
    if (stats.isEmpty) return;

    final wrapper = {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'list': [
        for (final stat in stats) {'typename': stat.typeName, 'count': stat.count, 'icon': stat.icon, 'type': stat.typeValue, 'unreadcount': stat.unreadCount},
      ],
    };
    await _storage.putString(_key, jsonEncode(wrapper));
  }
}
