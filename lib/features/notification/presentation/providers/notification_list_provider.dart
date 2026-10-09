import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/notification_repository.dart';

/// 通知列表页状态
class NotificationListState {
  /// 是否加载中
  final bool loading;

  /// 错误信息（非 null 表示加载失败）
  final String? errorMessage;

  /// 当前选中的分类入口
  final NotificationCategory selectedCategory;

  /// 各分类未读摘要（顶部入口角标）
  final List<NotificationCategorySummary> summaries;

  /// 当前分类的通知列表
  final List<NotificationMessage> messages;

  const NotificationListState({
    this.loading = false,
    this.errorMessage,
    this.selectedCategory = NotificationCategory.system,
    this.summaries = const [],
    this.messages = const [],
  });

  bool get hasError => errorMessage != null;

  /// 首次加载（尚无列表数据）时展示整页加载态；下拉刷新与切换分类时保留旧摘要
  bool get showLoading => loading && messages.isEmpty;

  /// 指定分类的未读数（无摘要或为 0 时不展示角标）
  int unreadCountOf(NotificationCategory category) {
    for (final summary in summaries) {
      if (summary.category == category) return summary.unreadCount;
    }
    return 0;
  }
}

final notificationListProvider = NotifierProvider<NotificationListNotifier, NotificationListState>(() => NotificationListNotifier());

/// 通知列表页控制器
///
/// 数据链路：Page → [notificationListProvider] → NotificationRepository → DataSource（当前为 Mock）
class NotificationListNotifier extends Notifier<NotificationListState> {
  @override
  NotificationListState build() => const NotificationListState();

  /// 加载分类摘要 + 当前分类通知列表（首屏 / 下拉刷新 / 切换分类共用）
  Future<void> load() async {
    if (state.loading) return;

    final category = state.selectedCategory;
    state = _copy(loading: true, clearError: true);
    final repository = ref.read(notificationRepositoryProvider);
    try {
      final summaryResp = await repository.getCategorySummaries();
      final messageResp = await repository.getMessages(category: category);

      if (summaryResp.success && summaryResp.data != null && messageResp.success && messageResp.data != null) {
        state = _copy(loading: false, clearError: true, summaries: summaryResp.data, messages: messageResp.data);
      } else {
        state = _copy(loading: false, errorMessage: _friendlyMessage(messageResp.message));
      }
    } catch (e) {
      debugPrint('[NotificationList] load error: $e');
      state = _copy(loading: false, errorMessage: '通知加载失败，请稍后重试');
    }
  }

  /// 切换分类入口：清空当前列表并加载新分类
  Future<void> selectCategory(NotificationCategory category) async {
    if (category == state.selectedCategory) return;
    state = _copy(selectedCategory: category, clearMessages: true, clearError: true);
    await load();
  }

  /// 后端 message 可能为空或为 `unknown error`，统一转成可展示的文案
  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '通知加载失败，请稍后重试';
    return message;
  }

  NotificationListState _copy({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    NotificationCategory? selectedCategory,
    List<NotificationCategorySummary>? summaries,
    List<NotificationMessage>? messages,
    bool clearMessages = false,
  }) {
    return NotificationListState(
      loading: loading ?? state.loading,
      errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
      selectedCategory: selectedCategory ?? state.selectedCategory,
      summaries: summaries ?? state.summaries,
      messages: clearMessages ? const [] : (messages ?? state.messages),
    );
  }
}
