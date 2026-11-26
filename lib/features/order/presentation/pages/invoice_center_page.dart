import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';

import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../providers/invoice_center_provider.dart';
import '../widgets/invoice_card.dart';

/// 发票中心页面
///
/// 结构（对齐设计稿）：白色头部（返回栏 + 页签行）+ 灰色背景发票卡片列表
/// 状态：Loading / Error（可重试）/ Empty / Content + 下拉刷新
class InvoiceCenterPage extends ConsumerStatefulWidget {
  const InvoiceCenterPage({super.key});

  @override
  ConsumerState<InvoiceCenterPage> createState() => _InvoiceCenterPageState();
}

class _InvoiceCenterPageState extends ConsumerState<InvoiceCenterPage> {
  @override
  void initState() {
    super.initState();
    // 首屏加载（postFrame，避免 build 期触发状态变更）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(invoiceCenterProvider);
      if (!state.hasLoaded && !state.isLoading) {
        ref.read(invoiceCenterProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceCenterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 白色头部：返回栏 + 页签行 ────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppBarRow(),
                  _TabRow(state: state),
                ],
              ),
            ),
            // ── 列表区 ────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(onRefresh: () => ref.read(invoiceCenterProvider.notifier).load(), child: _buildBody(state)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(InvoiceCenterState state) {
    if (state.isLoading && state.invoices.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: AppLoading()),
        ],
      );
    }
    if (state.errorMessage != null && state.invoices.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          AppError(message: state.errorMessage!, onRetry: () => ref.read(invoiceCenterProvider.notifier).load()),
        ],
      );
    }
    final filtered = state.filteredInvoices;
    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: AppEmpty(message: '暂无发票')),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 24),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => context.push('/orders/invoices/detail/${filtered[index].id}'),
        child: InvoiceCard(invoice: filtered[index]),
      ),
    );
  }
}

// ── 返回 + 标题行 ───────────────────────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  const _AppBarRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: AppPageHeader(
        height: 44,
        left: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 36,
            height: 44,
            child: Align(alignment: Alignment.centerLeft, child: Image.asset('assets/images/order/icon_back.png', width: 24, height: 24)),
          ),
        ),
        center: const Text(
          '发票中心',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
        ),
      ),
    );
  }
}

// ── 页签行（全部 / 待开票 / 已开票 + 筛选） ─────────────────────────────
class _TabRow extends ConsumerWidget {
  final InvoiceCenterState state;

  const _TabRow({required this.state});

  static const _tabs = ['全部', '待开票', '已开票'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(invoiceCenterProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              _TabLabel(text: _tabs[i], isActive: state.activeTabIndex == i, onTap: () => notifier.selectTab(i)),
              if (i < _tabs.length - 1) const SizedBox(width: 32),
            ],
          ],
        ),
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF213775) : const Color(0xFF1A1D1C),
            ),
          ),
          const SizedBox(height: 4),
          // 选中态短下划线
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(color: isActive ? const Color(0xFF213775) : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          ),
        ],
      ),
    );
  }
}
