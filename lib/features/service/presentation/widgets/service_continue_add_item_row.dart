import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../core/utils/money.dart';
import '../providers/service_cart_provider.dart';

/// 继续加购商品行
///
/// 布局：商品图(80×80) + 名称+价格列 + 加号圆形按钮
class ServiceContinueAddItemRow extends StatelessWidget {
  final ContinueAddProduct product;
  final VoidCallback onAdd;

  const ServiceContinueAddItemRow({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 名称 + 价格列
            Expanded(
              child: SizedBox(
                height: 74,
                child: Stack(
                  children: [
                    // 自营标签
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 28,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.serviceTabActive,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: const Center(
                          child: Text(
                            '自营',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 16,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Money.fromCents(product.priceCents).format(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 38),
            // 加号圆形按钮（36×36）
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.serviceTabActive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
