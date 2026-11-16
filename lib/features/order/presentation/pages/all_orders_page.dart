import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/all_orders_provider.dart';
import '../widgets/order_card.dart';

/// 全部订单页面（商城订单 + 积分订单 + 服务订单混合展示）
class AllOrdersPage extends ConsumerStatefulWidget {
  final String? initialStatus;
  const AllOrdersPage({super.key, this.initialStatus});

  @override
  ConsumerState<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends ConsumerState<AllOrdersPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  int get _initialTab => switch (widget.initialStatus) {
    'pending_payment' => 1,
    'pending_shipment' => 2,
    'shipped' => 3,
    'pending_evaluation' => 4,
    'refunding' => 5,
    _ => 0,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadNearBottom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(allOrdersProvider.notifier).initialize(tabIndex: _initialTab);
    });
  }

  @override
  void didUpdateWidget(covariant AllOrdersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _searchController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(allOrdersProvider.notifier).initialize(tabIndex: _initialTab);
      });
    }
  }

  void _loadNearBottom() {
    if (_scrollController.position.extentAfter < 240) {
      ref.read(allOrdersProvider.notifier).loadMore();
    }
  }

  void _search() {
    FocusScope.of(context).unfocus();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    ref.read(allOrdersProvider.notifier).search(_searchController.text);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allOrdersProvider);
    final notifier = ref.read(allOrdersProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: Column(
          children: [
            Container(height: MediaQuery.paddingOf(context).top, color: Colors.white),
            Expanded(
              child: SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: notifier.loadOrders,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // 白色头部区域（包含顶部导航栏与二级 Tab 导航栏）
                      SliverToBoxAdapter(
                        child: _HeaderSection(controller: _searchController, onSearch: _search),
                      ),
                      if (state.isLoading && state.orders.isNotEmpty) const SliverToBoxAdapter(child: LinearProgressIndicator()),
                      // 订单列表（灰色背景滚动区域）
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.compactPageMargin, AppSpacing.md, AppSpacing.compactPageMargin, AppSpacing.xxl),
                        sliver: state.isLoading && state.orders.isEmpty
                            ? const SliverToBoxAdapter(child: Center(child: AppLoading()))
                            : state.orders.isEmpty && state.error != null
                            ? SliverToBoxAdapter(
                                child: AppError(message: state.error!, onRetry: notifier.loadOrders),
                              )
                            : state.orders.isEmpty
                            ? const SliverToBoxAdapter(child: AppEmpty(message: '暂无订单'))
                            : SliverList.builder(
                                itemCount: state.orders.length,
                                itemBuilder: (context, index) =>
                                    OrderCard(item: state.orders[index], onCancelOrder: notifier.cancelOrder, onConfirmReceived: notifier.confirmReceived),
                              ),
                      ),
                      if (state.orders.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                            child: state.isLoadingMore
                                ? const Center(child: AppLoading())
                                : Center(
                                    child: state.hasMore
                                        ? TextButton(onPressed: notifier.loadMore, child: const Text('加载更多'))
                                        : const Text('没有更多订单了', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 白色头部容器 ──────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  const _HeaderSection({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopNavBar(controller: controller, onSearch: onSearch),
          const SizedBox(height: 12),
          const _TabRow(),
        ],
      ),
    );
  }
}

// ── 顶部导航栏（后退 + 全部订单 + 搜索框 + 筛选） ────────────────
class _TopNavBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  const _TopNavBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 22),
            onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const Text(
            '全部订单',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF213775), width: 1),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) => Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: Color(0xFF213775)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => onSearch(),
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          hintText: '商品名称/订单编号',
                          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF949599)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    if (value.text.isNotEmpty)
                      IconButton(
                        tooltip: '清空搜索',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 40),
                        iconSize: 16,
                        icon: const Icon(Icons.close, color: Color(0xFF949599)),
                        onPressed: () {
                          controller.clear();
                          onSearch();
                        },
                      ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSearch,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: Text(
                            '搜索',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // IconButton(
          //   tooltip: '筛选订单',
          //   onPressed: () {},
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(minWidth: 28, minHeight: 40),
          //   icon: Image.asset('assets/images/order/icon_filter.png', width: 28, height: 22),
          // ),
        ],
      ),
    );
  }
}

// ── Tab 行（二级导航栏，支持滑动，带选中变色加粗与指示横线） ───────────────
class _TabRow extends ConsumerStatefulWidget {
  const _TabRow();

  static const _tabs = AllOrdersNotifier.tabLabels;

  @override
  ConsumerState<_TabRow> createState() => _TabRowState();
}

class _TabRowState extends ConsumerState<_TabRow> {
  final _scrollController = ScrollController();
  final _tabKeys = List<GlobalKey>.generate(_TabRow._tabs.length, (_) => GlobalKey());
  int? _lastVisibleTab;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureActiveTabVisible(int active) {
    if (_lastVisibleTab == active) return;
    _lastVisibleTab = active;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _tabKeys[active].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, alignment: 0.5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(allOrdersProvider).activeTabIndex;
    final notifier = ref.read(allOrdersProvider.notifier);
    _ensureActiveTabVisible(active);

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_TabRow._tabs.length, (index) {
          final isSelected = active == index;
          return Padding(
            padding: EdgeInsets.only(right: index == _TabRow._tabs.length - 1 ? 0 : 32.0),
            child: Container(
              key: _tabKeys[index],
              child: _TabLabel(text: _TabRow._tabs[index], isActive: isSelected, onTap: () => notifier.selectTab(index)),
            ),
          );
        }),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabLabel({required this.text, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF213775) : AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 4,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(color: isActive ? const Color(0xFF213775) : Colors.transparent, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}
