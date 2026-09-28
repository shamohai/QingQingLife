import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../providers/points_rules_provider.dart';

/// 积分规则页面
///
/// 入口路径：积分商城 → 积分明细 → 右上角「积分说明」
class PointsRulesPage extends StatelessWidget {
  const PointsRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ① 自定义 AppBar（仅返回按钮 + 标题）
            const _AppBarRow(),
            // ② 视觉分隔占位
            const SizedBox(height: 8),
            // ③ 可滚动正文区
            Expanded(child: _RulesContent()),
            // ④ 底部装饰图
            Image.asset('assets/images/points/rules_bottom_deco.png', width: double.infinity, height: 60, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}

// ── ① 自定义 AppBar 行（仅返回 + 标题） ────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  const _AppBarRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            '积分规则',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}

// ── ③ 可滚动正文区（含 Loading / Error / Data 三种状态） ───────────────────
class _RulesContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(pointsRulesProvider);

    return asyncData.when(
      loading: () => const Center(child: AppLoading()),
      error: (_, _) => const Center(child: AppEmpty(message: '加载失败，请稍后重试')),
      data: (rulesText) => SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '青轻生活馆APP积分商城积分规则',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.5),
            ),
            const SizedBox(height: 2),
            Text(
              rulesText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
