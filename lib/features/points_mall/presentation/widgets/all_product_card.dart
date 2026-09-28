import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../data/models/get_credit_product_list_model.dart';
import '../../data/models/get_recommend_product_list_model.dart';

/// 全部商品网格中的商品卡片
///
/// 图片正方形，名称最多两行截断，底部为积分价格 + 兑换按钮。
/// 卡片宽度随屏幕自适应（由 SliverGrid childAspectRatio 控制）。
class AllProductCard extends StatelessWidget {
  final CreditProductItem item;
  final VoidCallback? onTap;

  const AllProductCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isService = item.productType == CreditProductType.serviceCouponIntegral ||
        item.productType == CreditProductType.serviceCouponSale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片：正方形，顶部圆角与卡片一致
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AppNetworkImage(
              url: item.imgUrl,
              height: 200,
              fit: BoxFit.cover,
              radius: 0,
            ),
          ),
          // 名称：16px Medium，最多两行
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 11, right: 11),
            child: Text(
              item.productName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2024),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 价格 + 按钮行
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.creditPrice}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                    ),
                    const Text(
                      ' 积分',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                    ),
                  ],
                ),
                SizedBox(
                  width: 54,
                  height: 26,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF2105), width: 1),
                      shape: const StadiumBorder(),
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isService ? '查看' : '兑换',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFFF2105)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}