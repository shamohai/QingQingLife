/// 通知中心领域模型
///
/// 对应接口：
///   - 类型统计：POST /api/common/app/getnotificationtypestat
///   - 通知列表：POST /api/common/app/getmynotificationlist
///
/// 类型体系完全由接口驱动：type 数值、类型名称、图标均以后端下发为准，
/// 客户端不维护本地类型清单；接口新增或调整类型时端上无需改动。
library;

/// 通知类型统计项（顶部类型入口）
///
/// 对应 getnotificationtypestat 响应 list 中的元素。
class NotificationTypeStat {
  /// 类型名称（接口 typename）
  final String typeName;

  /// 当前类型的总数量
  final int count;

  /// 类型图标地址（接口 icon，可能为空）
  final String icon;

  /// 接口下发的原始 type 数值（tab 身份与列表查询过滤值，客户端不转译）
  final int typeValue;

  /// 当前类型的未读数量
  final int unreadCount;

  const NotificationTypeStat({required this.typeName, required this.count, required this.icon, required this.typeValue, required this.unreadCount});

  /// 展示用名称：接口未下发 typename 时使用通用占位文案
  String get displayName {
    final name = typeName.trim();
    return name.isEmpty ? '通知' : name;
  }

  factory NotificationTypeStat.fromJson(Map<String, dynamic> json) {
    return NotificationTypeStat(
      typeName: json['typename']?.toString() ?? '',
      count: _asInt(json['count']),
      icon: _asString(json['icon']),
      typeValue: _asInt(json['type']),
      unreadCount: _asInt(json['unreadcount']),
    );
  }

  NotificationTypeStat copyWith({int? unreadCount}) {
    return NotificationTypeStat(typeName: typeName, count: count, icon: icon, typeValue: typeValue, unreadCount: unreadCount ?? this.unreadCount);
  }
}

/// 通知列表项
///
/// 对应 getmynotificationlist 响应 list 中的元素。
class NotificationMessage {
  /// 通知 id（接口 notificationid）
  final int id;

  /// 接口下发的原始 type 数值（与类型统计 tab 的 [NotificationTypeStat.typeValue] 对应）
  final int typeValue;

  /// 标题
  final String title;

  /// 内容
  final String content;

  /// 通知发送时间（接口 createtime，原样保留后端字符串）
  final String createTime;

  /// 是否已读：true 已读 / false 未读
  final bool isRead;

  const NotificationMessage({
    required this.id,
    required this.typeValue,
    required this.title,
    required this.content,
    required this.createTime,
    required this.isRead,
  });

  NotificationMessage copyWith({bool? isRead}) {
    return NotificationMessage(id: id, typeValue: typeValue, title: title, content: content, createTime: createTime, isRead: isRead ?? this.isRead);
  }

  bool get isUnread => !isRead;

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: _asInt(json['notificationid']),
      typeValue: _asInt(json['type']),
      title: _asString(json['title']),
      content: _asString(json['content']),
      createTime: _asString(json['createtime']),
      isRead: _asBool(json['read']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim() ?? '';
  return text == 'true' || text == '1';
}
