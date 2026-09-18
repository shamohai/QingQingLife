import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/models/points_mall_home_data.dart';

/// 积分商城商品行（横向：图片 + 名称 + 积分 + 兑换按钮）
///
/// 当 product.type == PointsProductType.service 时，点击整行跳转至服务商品详情页；
/// 否则仅"兑换"按钮可点击。
class PointsProductRow extends StatelessWidget {
  final PointsProduct product;
  final VoidCallback? onExchange;
  final VoidCallback? onServiceTap;

  const PointsProductRow({
    super.key,
    required this.product,
    this.onExchange,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isService = product.type.name == 'service';

    return MouseRegion(
      cursor: isService ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isService ? onServiceTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  url: product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 名称 + 服务标签
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurface, fontWeight: FontWeight.w500, height: 1.3),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isService)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x1AFF2105),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '服务',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${product.points}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF2105)),
                          ),
                          const Text(
                            ' 积分',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                          ),
                          const Spacer(),
                          if (isService)
                            OutlinedButton(
                              onPressed: onServiceTap,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF2105), width: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                shape: const StadiumBorder(),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '查看',
                                style: TextStyle(fontSize: 10, color: Color(0xFFFF2105), fontWeight: FontWeight.w500),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: onExchange,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF2105), width: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                shape: const StadiumBorder(),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '兑换',
                                style: TextStyle(fontSize: 10, color: Color(0xFFFF2105), fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
