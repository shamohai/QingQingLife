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

class _AllOrdersPageState extends ConsumerState<AllOrdersPage> {
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
            // 白色头部区域（包含顶部导航栏与二级 Tab 导航栏）
            const SliverToBoxAdapter(child: _HeaderSection()),
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
      delegate: SliverChildBuilderDelegate((context, index) => OrderCard(item: filtered[index]), childCount: filtered.length),
    );
  }
}

// ── 白色头部容器 ──────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

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
        children: const [_TopNavBar(), SizedBox(height: 12), _TabRow()],
      ),
    );
  }
}

// ── 顶部导航栏（后退 + 全部订单 + 搜索框 + 外侧搜索按钮 同一行） ──────
class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 4),
          const Text(
            '全部订单',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF213775), width: 1),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 18, color: Color(0xFF213775)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '商品名称/订单编号',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Color(0xFF949599)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 点击搜索处理
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                '搜索',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 行（二级导航栏，支持滑动，带选中变色加粗与指示横线） ───────────────
class _TabRow extends ConsumerWidget {
  const _TabRow();

  static const List<String> _tabs = ['全部订单', '待付款', '待发货', '待收货/待核销', '评价', '售后/退款'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(allOrdersProvider).activeTabIndex;
    final notifier = ref.read(allOrdersProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = active == index;
          return Padding(
            padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 24.0),
            child: _TabLabel(text: _tabs[index], isActive: isSelected, onTap: () => notifier.selectTab(index)),
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
            height: 3,
            width: isActive ? 28 : 0,
            decoration: BoxDecoration(color: isActive ? const Color(0xFF213775) : Colors.transparent, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}
