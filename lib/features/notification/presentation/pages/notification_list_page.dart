import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../member/presentation/providers/user_profile_provider.dart';
import '../../domain/models/notification_models.dart';
import '../providers/notification_list_provider.dart';
import '../widgets/notification_detail_dialog.dart';
import '../widgets/notification_message_card.dart';
import '../widgets/notification_type_tabs.dart';

/// 通知列表页（/notifications）
///
/// 结构：
///   顶部区块（#DFEBFF）：返回栏「通知列表」+ 类型入口（数据来自 getnotificationtypestat）
///   列表区（#D5E2F8）：当前类型的通知卡片（数据来自 getmynotificationlist）
///   点击卡片或「查看详情」打开详情弹窗，并调用 marknotificationasread 标记已读。
///
/// 数据链路：Page → notificationListProvider → NotificationRepository → NotificationRemoteDataSource
class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 接近底部时加载下一页
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(notificationListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5E2F8),
        body: Column(
          children: [
            // ── 顶部区块：返回栏 + 类型入口 ─────────────────────────
            _buildHeader(state, notifier),

            // ── 通知列表区 ─────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(onRefresh: () => notifier.load(), child: _buildBody(state, notifier)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationListState state, NotificationListNotifier notifier) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFDFEBFF),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(state, notifier),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: NotificationTypeTabs(selected: state.selectedTypeValue, stats: state.typeStats, onSelect: notifier.selectType),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部返回栏：标题左对齐，右侧与标题同行放置「全部已读」小刷子
  Widget _buildAppBar(NotificationListState state, NotificationListNotifier notifier) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF14203A)),
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            '通知列表',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF14203A)),
          ),
          const Spacer(),
          _buildMarkAllReadButton(state, notifier),
        ],
      ),
    );
  }

  /// 「全部已读」扫把按钮：点击调用标记已读接口（不传通知 id，type = -1），
  /// 成功后清零页面所有类型角标并同步「我的」页面消息入口角标。
  ///
  /// 44×44 点击区、图标正中：返回栏行高 44 且顶部即可视区顶（SafeArea 已剔除状态栏），
  /// 图标上下空隙 (44-20)/2 = 12，与右侧水平空隙 12 相等。
  Widget _buildMarkAllReadButton(NotificationListState state, NotificationListNotifier notifier) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: state.markingAllRead ? null : () => _markAllRead(notifier),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: state.markingAllRead
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14203A))),
                )
              : const Icon(Icons.cleaning_services, size: 20, color: Color(0xFF14203A)),
        ),
      ),
    );
  }

  /// 全部已读：接口成功后本地清零角标，并同步「我的」页面消息入口角标
  Future<void> _markAllRead(NotificationListNotifier notifier) async {
    final success = await notifier.markAllAsRead();
    if (success) {
      // 同步清零「我的」页面头部消息入口角标
      ref.read(userProfileProvider.notifier).clearUnreadMessageCount();
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(success ? '已全部标为已读' : '操作失败，请稍后重试'), behavior: SnackBarBehavior.floating));
  }

  /// 列表区：加载 / 错误 / 空 / 内容四种状态（均支持下拉刷新）
  Widget _buildBody(NotificationListState state, NotificationListNotifier notifier) {
    if (state.showLoading) {
      return _buildScrollableCentered(const AppLoading());
    }
    if (state.hasError && state.messages.isEmpty) {
      return _buildScrollableCentered(AppError(message: state.errorMessage!, onRetry: () => notifier.load()));
    }
    if (state.messages.isEmpty) {
      return _buildScrollableCentered(const AppEmpty(message: '暂无通知', icon: Icons.notifications_none));
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 24 + MediaQuery.paddingOf(context).bottom),
      // 底部追加一个加载更多的占位项
      itemCount: state.messages.length + (state.loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= state.messages.length) return const _LoadMoreIndicator();

        final message = state.messages[index];
        final stat = state.statOf(message.typeValue);
        return NotificationMessageCard(
          message: message,
          // 类型名称与图标均来源于类型统计接口
          typeName: stat?.displayName ?? '通知',
          iconUrl: stat?.icon ?? '',
          onDetailTap: () => _openDetail(message, stat?.displayName ?? '通知'),
        );
      },
    );
  }

  /// 点击详情：先标记已读，再打开弹窗展示全部字段
  Future<void> _openDetail(NotificationMessage message, String typeName) async {
    final notifier = ref.read(notificationListProvider.notifier);
    notifier.markAsRead(message);
    await NotificationDetailDialog.show(context, message: message, typeName: typeName);
  }

  /// 让加载 / 错误 / 空态在列表区居中且保留下拉刷新手势
  Widget _buildScrollableCentered(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// 列表底部「加载中」占位
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5C79B4))),
      ),
    );
  }
}
