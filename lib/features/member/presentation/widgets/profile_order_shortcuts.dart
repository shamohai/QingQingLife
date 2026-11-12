import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';

/// 订单状态筛选 key（与后端 order status 字段对应）
enum OrderFilterStatus {
  all('all'),
  pendingPayment('pending_payment'),
  pendingShipment('pending_shipment'),
  shipped('shipped'),
  pendingEvaluation('pending_evaluation'),
  refunding('refunding');

  const OrderFilterStatus(this.value);
  final String value;
}

/// 我的订单快捷入口卡片
///
/// 标题行（我的订单 / 全部订单 >）+ 5 个状态入口。
/// 角标数量来源于订单状态数量接口 —— 后端暂未提供对应字段，
/// 当前默认不显示角标（badgeCount > 0 时显示），接入后透传即可。
class ProfileOrderShortcuts extends StatelessWidget {
  const ProfileOrderShortcuts({super.key});

  static const List<_OrderShortcutConfig> _items = [
    _OrderShortcutConfig(icon: Icons.payment_outlined, label: '待付款', status: OrderFilterStatus.pendingPayment),
    _OrderShortcutConfig(icon: Icons.inventory_2_outlined, label: '待发货', status: OrderFilterStatus.pendingShipment),
    _OrderShortcutConfig(icon: Icons.local_shipping_outlined, label: '待收货', status: OrderFilterStatus.shipped),
    _OrderShortcutConfig(icon: Icons.mood_outlined, label: '评价', status: OrderFilterStatus.pendingEvaluation),
    _OrderShortcutConfig(icon: Icons.currency_yuan, label: '退款/售后', status: OrderFilterStatus.refunding),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          // ── 标题行 ────────────────────────────────────────────────
          Row(
            children: [
              const Text(
                '我的订单',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(RouteNames.orders),
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部订单',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 5 个状态入口 ──────────────────────────────────────────
          Row(children: _items.map((cfg) => _OrderShortcutItem(cfg: cfg)).toList()),
        ],
      ),
    );
  }
}

class _OrderShortcutConfig {
  final IconData icon;
  final String label;
  final OrderFilterStatus status;
  final int badgeCount;

  const _OrderShortcutConfig({required this.icon, required this.label, required this.status}) : badgeCount = 0;
}

class _OrderShortcutItem extends StatelessWidget {
  final _OrderShortcutConfig cfg;

  const _OrderShortcutItem({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.push(Uri(path: RouteNames.orders, queryParameters: {'status': cfg.status.value}).toString());
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: cfg.label == '退款/售后' ? const _YuanCircleIcon() : Icon(cfg.icon, size: 30, color: const Color(0xFF1A1D1C)),
                ),
                if (cfg.badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(color: const Color(0xFFFF4D4F), borderRadius: BorderRadius.circular(9)),
                      alignment: Alignment.center,
                      child: Text(
                        cfg.badgeCount > 99 ? '99+' : '${cfg.badgeCount}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cfg.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// 退款/售后：圆形描边 + ¥ 图标（对应设计稿样式）
class _YuanCircleIcon extends StatelessWidget {
  const _YuanCircleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1A1D1C), width: 1.6),
      ),
      alignment: Alignment.center,
      child: const Text(
        '¥',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C), height: 1.0),
      ),
    );
  }
}
