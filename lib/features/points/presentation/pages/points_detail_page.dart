import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_detail_provider.dart';
import '../widgets/points_record_item.dart';
import '../../../../../app/router/route_names.dart';

/// 积分明细页面
class PointsDetailPage extends ConsumerStatefulWidget {
  const PointsDetailPage({super.key});

  @override
  ConsumerState<PointsDetailPage> createState() => _PointsDetailPageState();
}

class _PointsDetailPageState extends ConsumerState<PointsDetailPage> {
  // 记录展开状态的月份 Key 集合，默认为空即全部折叠
  final Set<String> _expandedMonths = {};

  void _toggleMonthExpanded(String monthKey) {
    setState(() {
      if (_expandedMonths.contains(monthKey)) {
        _expandedMonths.remove(monthKey);
      } else {
        _expandedMonths.add(monthKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // 1. 渐变背景：高度 330px
            Container(
              height: 330,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFC65E), Color(0xFFF3F5F7)]),
              ),
            ),
            // 2. Banner 内容区（AppBar + 当前积分）
            _buildBannerContent(context, state),
            // 3. 独立月份卡片列表：作为 Root Stack 的直接子节点，设置 top 偏移实现重叠，确保手势完全可以正常响应
            Padding(padding: const EdgeInsets.only(top: 200), child: _buildRecordList(context, state)),
          ],
        ),
      ),
    );
  }

  // ── Banner 内容区：AppBar + 余额展示 ──────────────────────────────
  Widget _buildBannerContent(BuildContext context, PointsDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // AppBar 行
        Padding(
          padding: const EdgeInsets.only(top: 22, right: 15),
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
                onTap: () => GoRouter.of(context).push(RouteNames.pointsRules),
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
          padding: const EdgeInsets.only(left: 32, top: 24, right: 22),
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
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: AppColors.onSurface, height: 1.1, letterSpacing: -0.5),
                    ),
                  ),
                  const SizedBox(height: 75),
                ],
              ),
              const _DecorationPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }

  // ── 积分记录列表容器（刷新指示器） ──────────────────────────────────
  Widget _buildRecordList(BuildContext context, PointsDetailState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(pointsDetailProvider.notifier).refresh(),
      child: state.isLoading && state.records.isEmpty
          ? const Center(child: AppLoading())
          : state.records.isEmpty
          ? const AppEmpty(message: '暂无积分记录')
          : _buildMonthAccordionList(state),
    );
  }

  // ── 独立月份折叠卡片列表 ─────────────────────────────────────────
  Widget _buildMonthAccordionList(PointsDetailState state) {
    final months = state.availableMonths;
    if (months.isEmpty) {
      return const AppEmpty(message: '暂无积分记录');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final monthKey = months[index];
        final monthRecords = state.getRecordsForMonth(monthKey);
        final income = state.getMonthlyIncome(monthKey);
        final expense = state.getMonthlyExpense(monthKey);
        final isExpanded = _expandedMonths.contains(monthKey);

        return Container(
          // 每个月份是一个独立的卡片，上下外侧间隔 10 (margin: bottom 10)
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 月份 Header 行（标题 + 紧挨着折叠/展开箭头，右侧不显示收益支出）
              InkWell(
                onTap: () => _toggleMonthExpanded(monthKey),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // 月份文本（如：2026年10月）
                      Text(
                        PointsDetailState.formatMonthDisplay(monthKey),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.0),
                      ),
                      const SizedBox(width: 4),
                      // 紧挨着月份文本的折叠/展开箭头
                      Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 24, color: AppColors.onSurface),
                    ],
                  ),
                ),
              ),
              // 2. 展开后的明细区域
              if (isExpanded) ...[
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 展开后的第一行：收益 / 支出 汇总
                      Row(
                        children: [
                          if (income > 0)
                            Text(
                              '收益${NumberFormat('####').format(income.toInt())}积分',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
                            ),
                          if (income > 0 && expense > 0) const SizedBox(width: 12),
                          if (expense > 0)
                            Text(
                              '支出${NumberFormat('####').format(expense.toInt())}积分',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
                            ),
                        ],
                      ),
                      // 展开后的第二行及以下：具体兑换/变动明细记录（每条明细之间均有分割横线）
                      ...monthRecords.expand(
                        (record) => [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
                          ),
                          PointsRecordItem(record: record),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

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


