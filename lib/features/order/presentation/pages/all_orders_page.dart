import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/all_orders_provider.dart';
import '../../domain/repositories/order_repository.dart';
import '../widgets/order_card.dart';

/// 全部订单页面（商城订单 + 积分订单 + 服务订单混合展示）
class AllOrdersPage extends ConsumerStatefulWidget {
  const AllOrdersPage({super.key});

  @override
  ConsumerState<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends ConsumerState<AllOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(allOrdersProvider.notifier).selectTab(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allOrdersProvider);
    final notifier = ref.read(allOrdersProvider.notifier);

    if (state.orders.isEmpty && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadOrders());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 白色头部区域（h=144，底部圆角14）
            const SliverToBoxAdapter(child: _HeaderSection()),
            // Tab 指示器条
            SliverToBoxAdapter(child: _TabIndicator(controller: _tabController)),
            // 订单列表（灰色背景滚动区域）
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
              sliver: state.isLoading && state.orders.isEmpty
                  ? const SliverToBoxAdapter(child: Center(child: AppLoading()))
                  : state.orders.isEmpty
                      ? const SliverToBoxAdapter(child: AppEmpty(message: '暂无订单'))
                      : _buildOrdersSliver(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSliver(AllOrdersState state, AllOrdersNotifier notifier) {
    final activeIndex = state.activeTabIndex;
    List<OrderCardItem> filtered;
    if (activeIndex == 0) {
      filtered = state.orders;
    } else {
      final statusMap = <int, OrderStatus>{
        1: OrderStatus.pendingPayment,
        2: OrderStatus.pendingShipment,
        3: OrderStatus.shipped,
        4: OrderStatus.completed,
        5: OrderStatus.refunding,
      };
      final targetStatus = statusMap[activeIndex];
      filtered = targetStatus != null ? state.orders.where((o) => o.status == targetStatus).toList() : state.orders;
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => OrderCard(item: filtered[index]),
        childCount: filtered.length,
      ),
    );
  }
}

// ── 白色头部容器（高 144，底部圆角 14） ───────────────────────────────
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 144,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppBarRow(),
          const SizedBox(height: 12),
          const _SearchBar(),
          const SizedBox(height: 18),
          const _TabRow(),
        ],
      ),
    );
  }
}

// ── 返回 + 标题行 ──────────────────────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  const _AppBarRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, top: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset('assets/images/order/icon_back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            '全部订单',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

// ── 搜索栏 ────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21),
      child: Container(
        height: 40,
        width: 248,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF213775), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset('assets/images/order/icon_filter.png', width: 16, height: 16, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '商品名称/订单编号',
                style: TextStyle(fontSize: 14, color: Color(0xFF949599)),
              ),
            ),
            const Text(
              '搜索',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

// ── Tab 行（纯 Row，不使用 TabBar） ──────────────────────────────────
class _TabRow extends ConsumerWidget {
  const _TabRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(allOrdersProvider).activeTabIndex;
    final notifier = ref.read(allOrdersProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: [
          _TabLabel(text: '全部订单', isActive: active == 0, onTap: () => notifier.selectTab(0)),
          const SizedBox(width: 32),
          _TabLabel(text: '待付款', isActive: active == 1, onTap: () => notifier.selectTab(1)),
          const SizedBox(width: 32),
          _TabLabel(text: '待发货', isActive: active == 2, onTap: () => notifier.selectTab(2)),
          const SizedBox(width: 32),
          _TabLabel(text: '待收货/待核销', isActive: active == 3, onTap: () => notifier.selectTab(3)),
          const SizedBox(width: 32),
          _TabLabel(text: '评价', isActive: active == 4, onTap: () => notifier.selectTab(4)),
          const SizedBox(width: 32),
          _TabLabel(text: '售后/退款', isActive: active == 5, onTap: () => notifier.selectTab(5)),
        ],
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
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          color: isActive ? const Color(0xFF213775) : AppColors.onSurface,
        ),
      ),
    );
  }
}

// ── Tab 指示器 pill（h=4，跟随 active index 动画） ──────────────────
class _TabIndicator extends StatefulWidget {
  final TabController controller;
  const _TabIndicator({required this.controller});

  @override
  State<_TabIndicator> createState() => _TabIndicatorState();
}

class _TabIndicatorState extends State<_TabIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  // 每个 tab 的宽度（根据设计稿文字宽度估算）
  static const _tabWidths = [64.0, 48.0, 48.0, 104.0, 32.0, 72.0];
  static const _tabGap = 32.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _anim = Tween<double>(begin: 0, end: 0).animate(_animController);
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!widget.controller.indexIsChanging) return;
    final newIndex = widget.controller.index;
    final newOffset = _offsetForIndex(newIndex);
    setState(() {
      _anim = Tween<double>(begin: _anim.value, end: newOffset).animate(_animController);
    });
    _animController.forward(from: 0);
  }

  double _offsetForIndex(int index) {
    double x = 0;
    for (int i = 0; i < index; i++) {
      x += _tabWidths[i] + _tabGap;
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return Positioned(
                left: _anim.value,
                child: Container(
                  width: 30,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF213775),
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
