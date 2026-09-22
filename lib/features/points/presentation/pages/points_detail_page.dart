import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_detail_provider.dart';
import '../widgets/points_record_item.dart';

/// 积分明细页面
class PointsDetailPage extends ConsumerWidget {
  const PointsDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pointsDetailProvider);
    final notifier = ref.read(pointsDetailProvider.notifier);

    if (state.records.isEmpty && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadRecords());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Stack(
          children: [
            // 渐变背景：高度 330px（比 Banner 内容高出约 80px，实现底部 80px 视觉重叠）
            Container(
              height: 330,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFC65E), Color(0xFFF3F5F7)]),
              ),
            ),
            // 前景内容：AppBar + 余额展示 + 月份 Tab + 记录列表
            Column(
              children: [
                _buildBannerContent(context, state),
                _buildMonthTabs(context, state, notifier),
                Expanded(child: _buildRecordList(context, ref, state)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner 内容区：AppBar + 余额展示 ──────────────────────────────
  Widget _buildBannerContent(BuildContext context, PointsDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AppBar 行
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 15),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: AppColors.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                '积分明细',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showPointsRule(context),
                child: const Text(
                  '积分说明',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        ),
        // 余额展示区
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前积分',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      NumberFormat('#,###').format(state.currentPoints),
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.1, letterSpacing: -0.5),
                    ),
                  ),
                ],
              ),
              const _DecorationPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }

  // ── 月份 Tab 切换（白色胶囊，纵向排列）─────────────────────────────
  Widget _buildMonthTabs(BuildContext context, PointsDetailState state, PointsDetailNotifier notifier) {
    final months = state.availableMonths;
    if (months.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 14, right: 14),
      child: Column(
        children: months.map((month) {
          final isSelected = month == state.selectedMonth;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => notifier.selectMonth(month),
              child: Container(
                width: MediaQuery.of(context).size.width - 28,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: isSelected ? Border.all(color: const Color(0xFF000000), width: 1.5) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    children: [
                      Text(
                        PointsDetailState.formatMonthDisplay(month),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.0),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          width: 9,
                          height: 6,
                          decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(3)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 积分记录列表：白色卡片（顶部无圆角，sticky header 无缝衔接）──
  Widget _buildRecordList(BuildContext context, WidgetRef ref, PointsDetailState state) {
    return Container(
      // 卡片顶部上移 80px，与 Banner 底部产生重叠
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        // 仅底部圆角 + 阴影；顶部与 sticky header 齐平，不裁剪
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
          boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: RefreshIndicator(
          onRefresh: () => ref.read(pointsDetailProvider.notifier).refresh(),
          child: state.isLoading && state.records.isEmpty
              ? const Center(child: AppLoading())
              : state.filteredRecords.isEmpty
              ? const AppEmpty(message: '暂无积分记录')
              : _buildSliverList(ref, state),
        ),
      ),
    );
  }

  // ── Sticky Header + 记录条目 ─────────────────────────────────────
  Widget _buildSliverList(WidgetRef ref, PointsDetailState state) {
    final records = state.filteredRecords;
    if (records.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return CustomScrollView(
      slivers: [
        // Sticky 月份汇总 header（紧贴白色卡片顶部，无间隙）
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: _MonthHeaderDelegate(
            monthKey: state.selectedMonth,
            income: state.getMonthlyIncome(state.selectedMonth),
            expense: state.getMonthlyExpense(state.selectedMonth),
          ),
        ),
        // 记录条目
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) => PointsRecordItem(record: records[index]), childCount: records.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  void _showPointsRule(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('积分说明'),
        content: const Text('积分规则：每日签到得10积分，消费1元得1积分，积分有效期12个月，到期前30天短信提醒。'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了'))],
      ),
    );
  }
}

// ── Sticky 月份 Header ─────────────────────────────────────────────
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String monthKey;
  final double income;
  final double expense;

  const _MonthHeaderDelegate({required this.monthKey, this.income = 0, this.expense = 0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final displayText = PointsDetailState.formatMonthDisplay(monthKey);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(17, 14, 17, 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.0),
              ),
              const SizedBox(height: 4),
              Text(
                income > 0 ? '收益${NumberFormat('#,###').format(income.toInt())}积分' : '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.expand_more, size: 9, color: AppColors.onSurface),
          const SizedBox(width: 8),
          if (expense > 0)
            Text(
              '支出${NumberFormat('#,###').format(expense.toInt())}积分',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 84;
  @override
  double get minExtent => 84;
  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate old) => monthKey != old.monthKey || income != old.income || expense != old.expense;
}

// ── 装饰占位图 ─────────────────────────────────────────────────────
/// 右侧积分装饰插画（蓝湖 Rectangle 365 切片，175×175 hdpi）
/// 对应设计稿中 group_15 右侧的 image_1
class _DecorationPlaceholder extends StatelessWidget {
  const _DecorationPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/points/points_detail_stars.png', width: 175, height: 175, fit: BoxFit.contain);
  }
}
