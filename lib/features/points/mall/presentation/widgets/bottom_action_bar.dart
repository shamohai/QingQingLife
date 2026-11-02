import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/auth_redirect.dart';
import '../../../../../app/router/route_names.dart';
import '../../../../../core/providers/session_provider.dart';
import '../../data/models/get_recommend_product_list_model.dart';
import '../../data/models/service_product_detail_model.dart';
import 'exchange_confirm_dialog.dart';
import 'tips_dialog.dart';

/// 积分商城服务商品详情 — 固定底部操作栏
///
/// 深蓝色渐变胶囊按钮，固定在页面底部，不随滚动移动。
/// 尺寸严格按设计稿归一化：bar 71px，CTA 337×42px。
class BottomActionBar extends ConsumerWidget {
  final ServiceProductDetail product;
  final String productId;

  const BottomActionBar({super.key, required this.product, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Center(
          child: GestureDetector(
            onTap: () => _handleExchange(context, ref),
            child: Container(
              width: 337,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]),
              ),
              child: const Center(
                child: Text(
                  '立即兑换',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExchange(BuildContext context, WidgetRef ref) async {
    // 详情页允许访客浏览；仅在点击兑换时校验登录，并把登录后的目标设为当前详情页。
    // 登录成功后不自动重放兑换，避免未经用户再次确认就发起兑换流程。
    final session = ref.read(sessionProvider.notifier);
    await session.ensureInitialized();
    final isLoggedIn = ref.read(sessionProvider) == SessionState.authenticated;

    if (!context.mounted) return;

    if (!isLoggedIn) {
      final returnTo = GoRouterState.of(context).uri.toString();
      GoRouter.of(context).push(loginLocationFor(returnTo));
      return;
    }

    final effectiveId = productId.isNotEmpty ? productId : (product.id.isNotEmpty ? product.id : 'service_001');

    if (product.productType == CreditProductType.serviceCouponSale) {
      final serviceCouponId = product.serviceCoupon?.couponConfigId ?? int.tryParse(effectiveId) ?? 0;
      if (serviceCouponId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('服务券信息无效，请稍后重试')));
        return;
      }
      GoRouter.of(context).push(RouteNames.serviceCouponConfirmOrderPath(serviceCouponId: serviceCouponId, count: 1));
      return;
    }

    // 2. auth 权限判断
    if (product.auth) {
      // 有权限 → 弹出兑换确认弹窗（蓝湖设计稿样式）
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: const Color(0x4D000000),
        barrierDismissible: false,
        builder: (_) => const ExchangeConfirmDialog(),
      );
      if (!context.mounted) return;
      if (confirmed == true) {
        GoRouter.of(context).push(RouteNames.confirmOrder.replaceFirst(':id', effectiveId));
      }
    } else {
      if (!context.mounted) return;
      // 无权限 → 弹 Tips 提示框
      await showDialog<bool>(
        context: context,
        barrierColor: const Color(0x4D000000), // rgba(0,0,0,0.3)
        builder: (_) => TipsDialog(title: '提示', content: (product.authTips?.isEmpty ?? true) ? '当前暂无兑换权限' : product.authTips!, confirmText: '确定'),
      );
    }
  }
}
