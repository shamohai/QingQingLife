import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/member_level_provider.dart';
import '../widgets/member_benefit_grid.dart';
import '../widgets/member_level_tabs.dart';
import '../widgets/member_monthly_benefits.dart';
import '../widgets/member_summary_card.dart';

/// 会员详情页（/member/level）
///
/// 结构（设计稿）：
///   蓝色渐变区：返回栏「会员详情」+ 等级页签 + 等级信息卡片 + 每月权益
///   白色区：会员权益标题 + 权益宫格（米橙色卡片）
/// 数据：
///   等级页签 ← getRankList   （POST /api/sys/app/getranklist）
///   等级权益 ← getRankDetail （POST /api/sys/app/getrankdetail）
class MemberLevelPage extends ConsumerStatefulWidget {
  const MemberLevelPage({super.key});

  @override
  ConsumerState<MemberLevelPage> createState() => _MemberLevelPageState();
}

class _MemberLevelPageState extends ConsumerState<MemberLevelPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memberLevelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberLevelProvider);
    // 等级列表由 getRankList 异步返回，首次加载完成前为空
    final hasLevels = state.levels.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () => ref.read(memberLevelProvider.notifier).load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // ── 蓝色渐变区：返回栏 + 等级页签 + 等级卡片 + 每月权益 ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9ACBF4), Color(0xFF6FA3EA)]),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildAppBar(context),
                        if (hasLevels) ...[
                          MemberLevelTabs(
                            levels: state.levels,
                            selectedIndex: state.selectedLevelIndex,
                            onSelect: (index) => ref.read(memberLevelProvider.notifier).selectLevel(index),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, AppSpacing.md, 0),
                            child: MemberSummaryCard(level: state.selectedLevel, growthValue: state.growthValue),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 0),
                            child: MemberMonthlyBenefits(coupons: state.monthlyCoupons),
                          ),
                        ] else
                          // 等级列表加载中/失败时的占位，避免等级卡片取空列表越界
                          const SizedBox(height: 120, child: Center(child: AppLoading())),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── 会员权益区 ────────────────────────────────────────
                _buildBenefitsSection(context, state),

                // 底部留白，避免内容贴底
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部返回栏（透明背景叠在渐变上，白字标题）
  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
                child: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
              ),
            ),
          ),
          const Align(
            child: Text(
              '会员详情',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 会员权益区：加载/错误/空/内容四种状态
  Widget _buildBenefitsSection(BuildContext context, MemberLevelState state) {
    final auths = state.benefitAuths;

    Widget content;
    if (state.showGridLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: AppLoading()),
      );
    } else if (state.hasError && state.detail == null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: AppError(message: state.errorMessage!, onRetry: () => ref.read(memberLevelProvider.notifier).load()),
      );
    } else if (auths.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: AppEmpty(message: '暂无会员权益', icon: Icons.diamond_outlined),
      );
    } else {
      final sortedAuths = [...auths]..sort((a, b) => a.sort.compareTo(b.sort));
      content = MemberBenefitGrid(auths: sortedAuths);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.xl, 16, AppSpacing.xl, 10),
          child: Text(
            '会员权益',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C)),
          ),
        ),
        content,
      ],
    );
  }
}
