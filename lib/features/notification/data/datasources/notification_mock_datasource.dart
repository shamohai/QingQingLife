import '../../domain/repositories/notification_repository.dart';
import '../../../../core/network/api_response.dart';

/// Mock 通知数据源 - 开发/测试环境使用
///
/// TODO(Mock): 通知中心后端接口尚未定义，当前返回本地 Mock 数据用于 UI 还原。
/// 系统通知列表（系统公告 + 4 条系统通知）文案与时间对齐设计稿（2026-10-01 12:30:09）；
/// 订单通知 / 服务通知列表设计稿未展示，为占位 Mock，待后端接口/设计源确认后替换。
/// 角标未读数对齐设计稿视觉（系统通知 99+、订单通知 3、服务通知不展示）。
class MockNotificationDataSource implements NotificationRepository {
  /// 设计稿统一时间：2026-10-01 12:30:09
  static final DateTime _designTime = DateTime(2026, 10, 1, 12, 30, 9);

  /// 各分类未读摘要（角标）
  static const List<NotificationCategorySummary> _summaries = [
    NotificationCategorySummary(category: NotificationCategory.system, unreadCount: 105),
    NotificationCategorySummary(category: NotificationCategory.order, unreadCount: 3),
    NotificationCategorySummary(category: NotificationCategory.service, unreadCount: 0),
  ];

  /// 系统通知列表（设计稿录入）
  static final List<NotificationMessage> _systemMessages = [
    NotificationMessage(
      id: 'n1',
      category: NotificationCategory.system,
      source: NotificationSource.announcement,
      title: '关于系统升级的公告',
      content: '为了让您更好的使用资源平台,我们正在对平台进行升级。升级期间暂时无法访问。给您带来的不便,敬请谅解',
      createTime: _designTime,
      isUnread: true,
    ),
    NotificationMessage(
      id: 'n2',
      category: NotificationCategory.system,
      source: NotificationSource.systemNotice,
      title: '积分到期提醒',
      content: '【积分到期提醒】尊敬的会员您好！您在青轻生活账户内有部分积分即将到期失效，逾期未使用将自动清零，无法恢复。',
      createTime: _designTime,
    ),
    NotificationMessage(
      id: 'n3',
      category: NotificationCategory.system,
      source: NotificationSource.systemNotice,
      title: '订单开票通知',
      content: '【开票通知】尊敬的用户，您的订单已完成，发票已经开具！电子发票可用于报销、对账、凭证留存，开票信息支持自定义抬头、税号。',
      createTime: _designTime,
    ),
    NotificationMessage(
      id: 'n4',
      category: NotificationCategory.system,
      source: NotificationSource.systemNotice,
      title: '会员升级提醒',
      content: '【会员升级提醒】亲爱的会员！您的成长值已达标，可升级更高会员等级啦✨升级解锁更多专属权益：积分加速、商城专属折扣、优先兑换好物、专属客服等。立即前往【我的 - 会员中心】查看并升级，畅享更多福利！',
      createTime: _designTime,
    ),
    NotificationMessage(
      id: 'n5',
      category: NotificationCategory.system,
      source: NotificationSource.systemNotice,
      title: '优惠券到期提醒',
      content: '【优惠券到期提醒】亲爱的会员，您有几张优惠券即将到期失效⚠️过期自动作废，无法恢复补发！',
      createTime: _designTime,
    ),
  ];

  /// 订单通知列表
  ///
  /// TODO(Mock): 设计稿未展示，占位数据，文案以后端接口/设计源为准。
  static final List<NotificationMessage> _orderMessages = [
    NotificationMessage(
      id: 'o1',
      category: NotificationCategory.order,
      source: NotificationSource.orderNotice,
      title: '订单发货通知',
      content: '【发货提醒】您的订单已发货，快递单号 SF1234567890，请留意物流信息，注意查收。',
      createTime: DateTime(2026, 10, 1, 11, 20, 35),
      isUnread: true,
    ),
    NotificationMessage(
      id: 'o2',
      category: NotificationCategory.order,
      source: NotificationSource.orderNotice,
      title: '订单签收提醒',
      content: '【签收提醒】您的订单已签收成功，感谢您的支持，期待再次为您服务！',
      createTime: DateTime(2026, 9, 30, 18, 05, 12),
      isUnread: true,
    ),
    NotificationMessage(
      id: 'o3',
      category: NotificationCategory.order,
      source: NotificationSource.orderNotice,
      title: '订单评价提醒',
      content: '【评价提醒】您的订单已完成，快来评价晒单，赢取积分奖励吧！',
      createTime: DateTime(2026, 9, 29, 09, 45, 30),
      isUnread: true,
    ),
  ];

  /// 服务通知列表
  ///
  /// TODO(Mock): 设计稿未展示，占位数据，文案以后端接口/设计源为准。
  static final List<NotificationMessage> _serviceMessages = [
    NotificationMessage(
      id: 's1',
      category: NotificationCategory.service,
      source: NotificationSource.serviceNotice,
      title: '预约成功通知',
      content: '【预约提醒】您预约的接机服务已确认，专属管家将提前与您联系，请保持手机畅通。',
      createTime: DateTime(2026, 9, 28, 15, 30, 8),
    ),
    NotificationMessage(
      id: 's2',
      category: NotificationCategory.service,
      source: NotificationSource.serviceNotice,
      title: '服务评价邀请',
      content: '【评价邀请】您的高尔夫服务已完成，诚邀您评价本次服务体验，您的建议是我们前进的动力！',
      createTime: DateTime(2026, 9, 27, 10, 12, 45),
    ),
  ];

  @override
  Future<ApiResponse<List<NotificationCategorySummary>>> getCategorySummaries() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse.success(_summaries);
  }

  @override
  Future<ApiResponse<List<NotificationMessage>>> getMessages({required NotificationCategory category}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    switch (category) {
      case NotificationCategory.system:
        return ApiResponse.success(_systemMessages);
      case NotificationCategory.order:
        return ApiResponse.success(_orderMessages);
      case NotificationCategory.service:
        return ApiResponse.success(_serviceMessages);
    }
  }
}
