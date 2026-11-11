import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/datasources/notification_type_stat_cache.dart';
import '../../domain/models/notification_models.dart';

/// 通知列表页状态
class NotificationListState {
  /// 是否加载中（首屏 / 切换类型）
  final bool loading;

  /// 是否正在加载更多
  final bool loadingMore;

  /// 是否正在执行「全部已读」请求（防重复点击，刷子图标可展示进行中状态）
  final bool markingAllRead;

  /// 错误信息（非 null 表示加载失败）
  final String? errorMessage;

  /// 当前选中的类型入口的接口 type 数值；null 表示「全部」
  final int? selectedTypeValue;

  /// 类型统计（顶部入口：icon / typename / type / unreadcount）
  final List<NotificationTypeStat> typeStats;

  /// 当前类型的通知列表
  final List<NotificationMessage> messages;

  /// 已加载到的页码（从 1 开始，0 表示尚未加载）
  final int pageIndex;

  /// 是否还有下一页
  final bool hasMore;

  const NotificationListState({
    this.loading = false,
    this.loadingMore = false,
    this.markingAllRead = false,
    this.errorMessage,
    this.selectedTypeValue,
    this.typeStats = const [],
    this.messages = const [],
    this.pageIndex = 0,
    this.hasMore = true,
  });

  bool get hasError => errorMessage != null;

  /// 首次加载（尚无列表数据）时展示整页加载态；下拉刷新与切换类型时保留旧数据
  bool get showLoading => loading && messages.isEmpty;

  /// 指定类型的未读数（无统计或为 0 时不展示角标）
  int unreadCountOf(int typeValue) {
    for (final stat in typeStats) {
      if (stat.typeValue == typeValue) return stat.unreadCount;
    }
    return 0;
  }

  /// 指定类型的统计数据（无匹配时返回 null）
  NotificationTypeStat? statOf(int typeValue) {
    for (final stat in typeStats) {
      if (stat.typeValue == typeValue) return stat;
    }
    return null;
  }
}

final notificationListProvider = NotifierProvider<NotificationListNotifier, NotificationListState>(NotificationListNotifier.new);

/// 通知列表页控制器
///
/// 数据链路：Page → [notificationListProvider] → NotificationRepository → NotificationRemoteDataSource
///
/// 未选择类型（[NotificationListState.selectedTypeValue] 为 null）时请求全部通知；
/// 选中某个类型入口后以该入口接口下发的原始 type 数值请求列表。
class NotificationListNotifier extends Notifier<NotificationListState> {
  static const int pageSize = 20;

  /// 类型统计本地缓存（接口返回前先行渲染 tab 与类型图标）
  final NotificationTypeStatCache _statCache = NotificationTypeStatCache();

  /// 是否已从缓存恢复过（整个 Notifier 生命周期只恢复一次）
  bool _statCacheRestored = false;

  /// 请求令牌：丢弃切换类型途中返回的旧响应
  int _requestToken = 0;

  @override
  NotificationListState build() => const NotificationListState();

  /// 加载类型统计 + 当前类型的第一页通知（首屏 / 下拉刷新 / 切换类型共用）
  ///
  /// 类型统计为 stale-while-revalidate：先恢复本地缓存渲染 tab（仅一次），
  /// 接口返回成功后刷新界面并写入缓存。
  Future<void> load() async {
    if (!_statCacheRestored) {
      _statCacheRestored = true;
      final cached = await _statCache.read();
      if (cached != null && cached.isNotEmpty && _statCacheSafe()) {
        state = _copy(typeStats: cached);
      }
    }

    final typeValue = state.selectedTypeValue;
    final token = ++_requestToken;
    state = _copy(loading: true, loadingMore: false, clearError: true);

    final repository = ref.read(notificationRepositoryProvider);
    try {
      final statResp = await repository.getTypeStats();
      final messageResp = await repository.getMessages(typeValue: typeValue, pageIndex: 1, pageSize: pageSize);
      if (token != _requestToken) return;

      if (!messageResp.success || messageResp.data == null) {
        state = _copy(loading: false, errorMessage: _friendlyMessage(messageResp.message));
        // 统计成功但列表失败：仍刷新 tab 数据与缓存
        if (statResp.success && statResp.data != null) _updateStats(statResp.data!);
        return;
      }

      final messages = messageResp.data!;
      state = _copy(
        loading: false,
        clearError: true,
        // 统计失败不影响列表展示，保留上一次的类型入口数据。
        typeStats: statResp.success && statResp.data != null ? statResp.data : null,
        messages: messages,
        pageIndex: 1,
        hasMore: messages.length >= pageSize,
      );
      if (statResp.success && statResp.data != null) _updateStats(statResp.data!);
    } catch (error) {
      if (token != _requestToken) return;
      AppLogger.error('load error', module: 'notification_list', error: error);
      state = _copy(loading: false, errorMessage: '通知加载失败，请稍后重试');
    }
  }

  /// 接口返回后刷新 tab 数据并写入本地缓存（下次进入先渲染缓存）
  void _updateStats(List<NotificationTypeStat> stats) {
    state = _copy(typeStats: stats);
    _statCache.write(stats);
  }

  /// 缓存恢复仅用于首屏渲染前的兜底，请求已发出后不再覆盖状态
  bool _statCacheSafe() => state.pageIndex == 0 && state.messages.isEmpty && !state.loading;

  /// 切换类型入口：清空当前列表并以该入口的原始 type 数值加载列表
  Future<void> selectType(int? typeValue) async {
    if (typeValue == state.selectedTypeValue) return;
    _requestToken++;
    state = _copy(selectedTypeValue: typeValue, selectedTypeExplicit: true, messages: const [], pageIndex: 0, hasMore: true, clearError: true);
    await load();
  }

  /// 加载下一页（滚动到底部触发）
  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;

    final typeValue = state.selectedTypeValue;
    final nextPage = state.pageIndex + 1;
    final token = ++_requestToken;
    state = _copy(loadingMore: true, clearError: true);

    try {
      final response = await ref.read(notificationRepositoryProvider).getMessages(typeValue: typeValue, pageIndex: nextPage, pageSize: pageSize);
      if (token != _requestToken) return;

      if (!response.success || response.data == null) {
        state = _copy(loadingMore: false, errorMessage: _friendlyMessage(response.message));
        return;
      }

      final next = response.data!;
      state = _copy(loadingMore: false, clearError: true, messages: [...state.messages, ...next], pageIndex: nextPage, hasMore: next.length >= pageSize);
    } catch (error) {
      if (token != _requestToken) return;
      AppLogger.error('load more error', module: 'notification_list', error: error);
      state = _copy(loadingMore: false, errorMessage: '加载更多失败，请稍后重试');
    }
  }

  /// 打开详情时标记该条通知已读。
  ///
  /// 接口失败不影响详情展示，仅在本地把这条置为已读并同步顶部角标。
  Future<void> markAsRead(NotificationMessage message) async {
    if (message.isRead) return;

    _markLocalAsRead(message);
    try {
      final response = await ref.read(notificationRepositoryProvider).markAsRead(notificationId: message.id);
      if (!response.success) {
        AppLogger.warning('markAsRead failed: ${response.message}', module: 'notification_list');
      }
    } catch (error) {
      AppLogger.error('markAsRead error', module: 'notification_list', error: error);
    }
  }

  /// 一键全部已读（顶部小刷子）。
  ///
  /// 调用 marknotificationasread 时不传通知 id、type 传 -1（全部类型）；
  /// 接口返回成功后才更新本地状态：所有消息置为已读、所有类型角标清零，
  /// 并同步清零「我的」页面头部消息入口角标。
  Future<bool> markAllAsRead() async {
    if (state.markingAllRead) return false;
    state = _copy(markingAllRead: true);

    try {
      final response = await ref.read(notificationRepositoryProvider).markAsRead(typeValue: -1);
      if (!response.success) {
        AppLogger.warning('markAllAsRead failed: ${response.message}', module: 'notification_list');
        return false;
      }

      if (!ref.mounted) return false;
      // 全部类型（含「全部」tab）的未读角标清零
      final clearedStats = [for (final stat in state.typeStats) stat.copyWith(unreadCount: 0)];
      state = _copy(
        // 当前列表内的消息全部置为已读
        messages: [for (final item in state.messages) item.copyWith(isRead: true)],
        typeStats: clearedStats,
        markingAllRead: false,
      );
      // 同步更新统计缓存，避免下次进入先渲染出旧角标
      if (clearedStats.isNotEmpty) _statCache.write(clearedStats);
      return true;
    } catch (error) {
      AppLogger.error('markAllAsRead error', module: 'notification_list', error: error);
      if (ref.mounted) state = _copy(markingAllRead: false);
      return false;
    }
  }

  /// 本地置为已读，并扣减对应类型与「全部」的未读数
  void _markLocalAsRead(NotificationMessage message) {
    final messages = [
      for (final item in state.messages)
        if (item.id == message.id) item.copyWith(isRead: true) else item,
    ];
    final stats = [
      for (final stat in state.typeStats)
        if (stat.typeValue == message.typeValue && stat.unreadCount > 0)
          NotificationTypeStat(typeName: stat.typeName, count: stat.count, icon: stat.icon, typeValue: stat.typeValue, unreadCount: stat.unreadCount - 1)
        else
          stat,
    ];
    state = _copy(messages: messages, typeStats: stats);
  }

  /// 后端 message 可能为空或为 `unknown error`，统一转成可展示的文案
  static String _friendlyMessage(String? raw) {
    final message = raw?.trim() ?? '';
    if (message.isEmpty || message == 'unknown error') return '通知加载失败，请稍后重试';
    return message;
  }

  NotificationListState _copy({
    bool? loading,
    bool? loadingMore,
    bool? markingAllRead,
    String? errorMessage,
    bool clearError = false,
    int? selectedTypeValue,
    bool selectedTypeExplicit = false,
    List<NotificationTypeStat>? typeStats,
    List<NotificationMessage>? messages,
    int? pageIndex,
    bool? hasMore,
  }) {
    return NotificationListState(
      loading: loading ?? state.loading,
      loadingMore: loadingMore ?? state.loadingMore,
      markingAllRead: markingAllRead ?? state.markingAllRead,
      errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
      selectedTypeValue: selectedTypeExplicit ? selectedTypeValue : state.selectedTypeValue,
      typeStats: typeStats ?? state.typeStats,
      messages: messages ?? state.messages,
      pageIndex: pageIndex ?? state.pageIndex,
      hasMore: hasMore ?? state.hasMore,
    );
  }
}
