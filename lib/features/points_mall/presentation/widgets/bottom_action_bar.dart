import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../data/models/service_product_detail_model.dart';

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
    // 1. 判断当前用户有没有登录
    final isLoggedIn = await ref.read(authProvider.notifier).isLoggedIn();

    if (!context.mounted) return;

    if (!isLoggedIn) {
      GoRouter.of(context).push(RouteNames.login);
      return;
    }

    final effectiveId = productId.isNotEmpty ? productId : (product.id.isNotEmpty ? product.id : 'service_001');

    // 2. 判断 auth 字段是否有权限购买
    if (product.auth) {
      GoRouter.of(context).push(RouteNames.confirmOrder.replaceFirst(':id', effectiveId));
    } else {
      // 3. 弹出类似浏览器的 confirm 窗口，点击确定跳转到确认订单页
      final confirmed = await AppDialog.show(
        context: context,
        title: '提示',
        content: product.authTips ?? '当前暂无兑换权限，是否确认前往兑换？',
        confirmText: '确定',
        cancelText: '取消',
      );

      if (!context.mounted) return;

      if (confirmed == true) {
        GoRouter.of(context).push(RouteNames.confirmOrder.replaceFirst(':id', effectiveId));
      }
    }
  }
}
