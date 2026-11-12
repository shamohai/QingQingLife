import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../providers/invoice_detail_provider.dart';

/// 发票申请记录详情页
///
/// 结构（对齐设计稿，页面骨架与 personal_info_page 一致）：
///   顶部 bg-top350 插画背景（底部渐隐衔接页面淡蓝底色）
///   → 透明返回栏「申请记录」（白字）→ 白色大卡片
///   （商品信息 + 订单信息 + 发票信息 + 时间信息 + 保存发票按钮）
class InvoiceDetailPage extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends ConsumerState<InvoiceDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(invoiceDetailProvider(widget.invoiceId));
      if (state.detail == null && !state.isLoading) {
        ref.read(invoiceDetailProvider(widget.invoiceId).notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4E2F7),
        // fit: expand 让 Stack 撑满视口（Scaffold body 的约束是松散的，
        // 否则 Stack 会被内容撑出的高度决定，背景无法铺满全屏）
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 顶部插画背景（底部渐隐，不随内容滚动）─────────────────
            Positioned(top: 0, left: 0, right: 0, child: _buildBanner()),

            // ── 前景内容 ───────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg),
                child: Column(
                  children: [
                    _buildNavBar(context),
                    // 卡片上沿与导航栏底部的距离（设计稿卡片顶 170 - 状态栏 44 - 导航栏 30 = 96）
                    const SizedBox(height: 96),
                    _buildCard(context, state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部插画背景（全宽等比） + 底部渐隐（衔接页面底色 #D4E2F7）
  ///
  /// 与 personal_info_page 的 _buildBanner 使用同一张背景图 bg-top350.png。
  Widget _buildBanner() {
    return Stack(
      children: [
        Image.asset('assets/images/member/bg-top350.png', width: double.infinity, fit: BoxFit.fitWidth),
        // 插画底部渐隐，与页面底色无缝衔接（设计稿渐隐区约 85）
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 85,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00D4E2F7), Color(0xFFD4E2F7)]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, InvoiceDetailState state) {
    if (state.isLoading && state.detail == null) {
      return Container(
        width: double.infinity,
        height: 420,
        decoration: _cardDecoration,
        child: const Center(child: AppLoading()),
      );
    }
    if (state.errorMessage != null && state.detail == null) {
      return Container(
        width: double.infinity,
        height: 420,
        decoration: _cardDecoration,
        child: Center(
          child: AppError(message: state.errorMessage!, onRetry: () => ref.read(invoiceDetailProvider(widget.invoiceId).notifier).load()),
        ),
      );
    }
    final detail = state.detail;
    if (detail == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 商品信息 ──────────────────────────────────────────────
          _ProductSection(detail: detail),
          const SizedBox(height: 16),
          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          // ── 订单信息 ──────────────────────────────────────────────
          _InfoRow(label: '订单编号', value: detail.orderNo),
          _InfoRow(label: '订单类型', value: detail.orderTypeText),
          const SizedBox(height: 14),
          // ── 发票信息 ──────────────────────────────────────────────
          _InfoRow(label: '发票类型', value: detail.invoiceTypeText),
          _InfoRow(label: '开票金额', value: '', valueWidget: _amountText(detail.amountCents)),
          const SizedBox(height: 14),
          // ── 时间信息 ──────────────────────────────────────────────
          _InfoRow(label: '下单时间', value: _formatTime(detail.orderTime)),
          _InfoRow(label: '申请时间', value: _formatTime(detail.applyTime)),
          _InfoRow(label: '开票时间', value: detail.invoiceTime != null ? _formatTime(detail.invoiceTime!) : '--'),
          const SizedBox(height: 20),
          // ── 保存发票按钮 ──────────────────────────────────────────
          _SaveInvoiceButton(invoiceId: detail.id),
        ],
      ),
    );
  }

  /// 透明返回栏（叠在头部插画上，白字标题）
  ///
  /// 与 personal_info_page.dart 的 _buildNavBar 逻辑保持一致：
  /// 固定高 30、返回图标左内边距 12 / 右 2、图标 20、标题 15 w500。
  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const Text(
            '申请记录',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
          ),
        ],
      ),
    );
  }

  static const _cardDecoration = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12)));

  static String _formatTime(DateTime time) {
    final mm = time.month.toString().padLeft(2, '0');
    final dd = time.day.toString().padLeft(2, '0');
    final hh = time.hour.toString().padLeft(2, '0');
    final mi = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '${time.year}-$mm-$dd $hh:$mi:$ss';
  }

  static Text _amountText(int amountCents) {
    final yuan = amountCents / 100;
    final yuanInt = yuan.toInt();
    final decimal = (yuan - yuanInt).toStringAsFixed(2).substring(1);
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF4030)),
        children: [
          const TextSpan(text: '¥', style: TextStyle(fontSize: 12)),
          TextSpan(text: yuanInt.toString(), style: const TextStyle(fontSize: 16)),
          TextSpan(text: decimal, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ── 商品信息区（图 + 标题/价格 + 标签/数量 + 规格） ─────────────────────
class _ProductSection extends StatelessWidget {
  final InvoiceDetail detail;

  const _ProductSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(detail.productImage, width: 92, height: 92, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      detail.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
                      children: [
                        const TextSpan(text: '¥', style: TextStyle(fontSize: 11)),
                        TextSpan(text: (detail.amountCents / 100).toStringAsFixed(2), style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < detail.productTags.length; i++) ...[
                    _ProductTag(label: detail.productTags[i]),
                    if (i < detail.productTags.length - 1) const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    '×${detail.quantity}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                detail.specText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 商品标签（红描边） ──────────────────────────────────────────────────
class _ProductTag extends StatelessWidget {
  final String label;

  const _ProductTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF4030), width: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xFFFF4030)),
      ),
    );
  }
}

// ── 信息行（label 左灰 / value 右灰，可替换自定义 value 组件） ───────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _InfoRow({required this.label, required this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
              ),
        ],
      ),
    );
  }
}

// ── 保存发票按钮（蓝描边胶囊） ──────────────────────────────────────────
class _SaveInvoiceButton extends StatelessWidget {
  final String invoiceId;

  const _SaveInvoiceButton({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    // TODO(交互): 「保存发票」的后端能力（电子发票文件下载/保存）尚未定义，暂为占位反馈
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存发票功能开发中，敬请期待'), duration: Duration(seconds: 1)));
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF213775), width: 1),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          '保存发票',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
        ),
      ),
    );
  }
}
