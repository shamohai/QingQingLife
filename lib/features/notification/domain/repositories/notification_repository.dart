import '../../../../core/network/api_response.dart';

/// 通知分类（顶部入口：系统通知 / 订单通知 / 服务通知）
enum NotificationCategory {
  system('系统通知'),
  order('订单通知'),
  service('服务通知');

  const NotificationCategory(this.label);

  final String label;
}

/// 通知来源（卡片头部标签，决定图标样式：系统公告 / 系统通知 / 订单通知 / 服务通知）
enum NotificationSource {
  announcement('系统公告'),
  systemNotice('系统通知'),
  orderNotice('订单通知'),
  serviceNotice('服务通知');

  const NotificationSource(this.label);

  final String label;
}

/// 通知分类摘要（顶部入口角标未读数）
class NotificationCategorySummary {
  final NotificationCategory category;

  /// 未读数（0 不展示角标）
  final int unreadCount;

  const NotificationCategorySummary({required this.category, required this.unreadCount});
}

/// 通知消息
class NotificationMessage {
  final String id;

  /// 所属分类（决定展示在哪个入口下）
  final NotificationCategory category;

  /// 来源（卡片头部标签）
  final NotificationSource source;

  final String title;
  final String content;
  final DateTime createTime;

  /// 未读（标题前展示红点）
  final bool isUnread;

  const NotificationMessage({
    required this.id,
    required this.category,
    required this.source,
    required this.title,
    required this.content,
    required this.createTime,
    this.isUnread = false,
  });

  /// 展示时间：yyyy-MM-dd HH:mm:ss
  String get formattedTime {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${createTime.year}-${two(createTime.month)}-${two(createTime.day)} '
        '${two(createTime.hour)}:${two(createTime.minute)}:${two(createTime.second)}';
  }
}

/// 通知中心仓库接口
///
/// TODO(Mock): 通知相关后端接口尚未定义，当前由 MockNotificationDataSource 提供数据；
/// 接口就绪后新增 Remote 数据源实现本接口，并在 repository_providers 中切换。
abstract class NotificationRepository {
  /// 获取各分类未读摘要（顶部入口角标）
  Future<ApiResponse<List<NotificationCategorySummary>>> getCategorySummaries();

  /// 获取指定分类的通知列表
  Future<ApiResponse<List<NotificationMessage>>> getMessages({required NotificationCategory category});
}
