import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/notification_list_provider.dart';
import '../widgets/notification_category_tabs.dart';
import '../widgets/notification_message_card.dart';

/// 通知列表页（/notifications）
///
/// 结构（设计稿）：
///   顶部区块（#DFEBFF）：返回栏「通知列表」+ 分类入口（系统通知 / 订单通知 / 服务通知）
///   列表区（#D5E2F8）：通知卡片列表，卡片底部「查看详情」进入详情（详情页待实现）
/// 数据链路：Page → notificationListProvider → NotificationRepository → DataSource
///
/// TODO(Mock): 通知接口尚未定义，当前数据由 MockNotificationDataSource 提供。
class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).load();
    });
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
            // ── 顶部区块：返回栏 + 分类入口 ─────────────────────────
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
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: NotificationCategoryTabs(selected: state.selectedCategory, summaries: state.summaries, onSelect: notifier.selectCategory),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部返回栏（标题左对齐，与设计稿一致）
  Widget _buildAppBar() {
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
        ],
      ),
    );
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12, 10, 12, 24 + MediaQuery.paddingOf(context).bottom),
      itemCount: state.messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => NotificationMessageCard(
        message: state.messages[index],
        onDetailTap: () {
          // TODO(通知详情): 通知详情页未实现，待接口与详情页就绪后替换为路由跳转。
          debugPrint('[NotificationList] 查看详情: ${state.messages[index].id}');
        },
      ),
    );
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
