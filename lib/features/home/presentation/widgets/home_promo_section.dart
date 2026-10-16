import 'package:flutter/material.dart';

import '../../../product/domain/repositories/product_repository.dart';
import 'home_new_user_gift_card.dart';
import 'home_available_products.dart';

/// 新人礼 + 可用商品组合模块（同一白色卡片容器）
/// 设计稿：白色卡片 414x429，圆角 14px，内部间距 12px
class HomePromoSection extends StatelessWidget {
  final List<HomeNewUserGift> gifts;
  final List<ProductCard> products;
  final VoidCallback? onManageServiceTap;

  const HomePromoSection({super.key, required this.gifts, required this.products, this.onManageServiceTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10), // 与上方 banner 间距 10px
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 5), // 左右边距
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)), // 设计稿 14px 圆角
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 新人礼区域
          HomeNewUserGiftCard(gifts: gifts),
          const SizedBox(height: 12),
          // 可用商品区域
          HomeAvailableProducts(products: products, onManageServiceTap: onManageServiceTap),
        ],
      ),
    );
  }
}
