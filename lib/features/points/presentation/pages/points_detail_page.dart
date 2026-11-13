import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/points_detail_provider.dart';
import '../widgets/points_record_item.dart';
import '../../../../app/router/route_names.dart';

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

    if (!state.isLoading && state.records.isEmpty && state.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadRecords());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. 渐变背景：高度 330px
            // Container(
            //   height: 330,
            //   // decoration: const BoxDecoration(
            //   //   gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFC65E), Color(0xFFF3F5F7)]),
            //   // ),
            // ),
            // 2. Banner 内容区（AppBar + 当前积分）
            _buildBannerContent(context, state),
            // 3. 独立月份卡片列表：作为 Root Stack 的直接子节点，设置 top 偏移实现重叠，确保手势完全可以正常响应
            Padding(padding: const EdgeInsets.only(top: 180), child: _buildRecordList(context, state)),
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
          padding: const EdgeInsets.only(right: 15, top: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.onSurface),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              const Text(
                '积分明细',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (kIsWeb) {
                    launchUrl(Uri.parse(RouteNames.pointsRulesUrl), webOnlyWindowName: '_blank');
                  } else {
                    GoRouter.of(context).push(RouteNames.pointsRules);
                  }
                },
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
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.1, letterSpacing: -0.5),
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

  // ── 积分记录列表容器 ──────────────────────────────────
  Widget _buildRecordList(BuildContext context, PointsDetailState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(child: AppLoading());
    }
    if (state.errorMessage != null && state.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => ref.read(pointsDetailProvider.notifier).refresh(), child: const Text('重试')),
          ],
        ),
      );
    }
    if (state.records.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(pointsDetailProvider.notifier).refresh(),
        child: ListView(
          children: const [
            SizedBox(height: 360),
            AppEmpty(message: '暂无积分记录'),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(pointsDetailProvider.notifier).refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification && notification.metrics.pixels >= notification.metrics.maxScrollExtent - 160) {
            ref.read(pointsDetailProvider.notifier).loadMore();
          }
          return false;
        },
        child: _buildMonthAccordionList(state),
      ),
    );
  }

  // ── 独立月份折叠卡片列表 ─────────────────────────────────────────
  Widget _buildMonthAccordionList(PointsDetailState state) {
    final months = state.availableMonths;
    if (months.isEmpty) {
      return const AppEmpty(message: '暂无积分记录');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && constraints.hasBoundedHeight && state.hasMore && !state.isLoading && !state.isLoadingMore) {
            final contentHeight = _estimateMonthListHeight(state, months);
            if (contentHeight <= constraints.maxHeight) {
              ref.read(pointsDetailProvider.notifier).loadMore();
            }
          }
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          itemCount: months.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == months.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: AppLoading()),
              );
            }
            final monthKey = months[index];
            final monthRecords = state.getRecordsForMonth(monthKey);
            final income = monthRecords.where((record) => record.change > 0).fold<int>(0, (sum, record) => sum + record.change);
            final expense = monthRecords.where((record) => record.change < 0).fold<int>(0, (sum, record) => sum + record.change.abs());
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
                                  '收益${NumberFormat('####').format(income)}积分',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
                                ),
                              if (income > 0 && expense > 0) const SizedBox(width: 12),
                              if (expense > 0)
                                Text(
                                  '支出${NumberFormat('####').format(expense)}积分',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.4),
                                ),
                            ],
                          ),
                          // 展开后的第二行及以下：具体兑换/变动明细记录（每条明细之间均有分割横线）
                          ...monthRecords.expand(
                            (record) => [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
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
      },
    );
  }

  double _estimateMonthListHeight(PointsDetailState state, List<String> months) {
    return months.fold<double>(10, (height, month) {
      final records = state.getRecordsForMonth(month);
      final expanded = _expandedMonths.contains(month);
      final cardHeight = expanded ? 82 + records.length * 78 : 56;
      return height + cardHeight + 10;
    });
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
