import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../core/utils/money.dart';
import '../providers/service_cart_provider.dart';

/// 购物车商品行（购酒享服务结算页专用）
///
/// 布局：左侧小图标 + 商品图(80×80) + 名称+价格列 + 自营标签 + 数量控制器
/// 自带货品卡片内部分割线（由父级 Container 管理圆角/阴影）
class ServiceCartItemRow extends StatelessWidget {
  final ServiceCartItem item;
  final VoidCallback onToggle;
  final ValueChanged<int> onQtyChanged;

  const ServiceCartItemRow({super.key, required this.item, required this.onToggle, required this.onQtyChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            // 左侧小图标
            const SizedBox(width: 20, height: 20, child: Icon(Icons.local_drink_rounded, size: 20, color: AppColors.serviceTabActive)),
            const SizedBox(width: 14),
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(width: 80, height: 80, color: AppColors.surfaceVariant),
              ),
            ),
            const SizedBox(width: 10),
            // 名称 + 价格列
            Expanded(
              child: SizedBox(
                height: 74,
                child: Stack(
                  children: [
                    // 自营标签（绝对定位，对应设计稿 left:138, top:72/166/260）
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 28,
                        height: 14,
                        decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.xs)),
                        child: const Center(
                          child: Text(
                            '自营',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // 名称 + 价格（在标签下方）
                    Positioned(
                      left: 0,
                      top: 16,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Money.fromCents(item.priceCents).format(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 数量控制器
            _QtyControl(
              quantity: item.quantity,
              onMinus: item.quantity > 1 ? () => onQtyChanged(item.quantity - 1) : null,
              onPlus: () => onQtyChanged(item.quantity + 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数量控制控件（- 数字 +）
class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  const _QtyControl({required this.quantity, this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Icon(Icons.remove_circle_outline, size: 22, color: onMinus == null ? AppColors.outlineVariant : AppColors.onSurface),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          child: Text(
            quantity.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onPlus,
          child: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.onSurface),
        ),
      ],
    );
  }
}
