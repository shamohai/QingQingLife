import 'package:flutter/material.dart';

import '../../../product/domain/repositories/product_repository.dart';

/// 首页底部推荐展示区（4个独立白色卡片错落网格 + 底部 bottom.png 及下箭头居中）
class HomeBottomRecommendSection extends StatelessWidget {
  final List<ProductCard> products;

  const HomeBottomRecommendSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 4个独立的白色模块卡片组成两列错落网格
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧列：模块 1（元宝专区图片卡片） + 模块 2（商品卡片）
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 模块 1：元宝图片卡片 (白色背景，圆角 14px)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/home/yuanbao.png',
                      fit: BoxFit.cover,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Text('元宝专区', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // 上下间距透出 home 背景色 (#213775)
                  // 模块 2：左侧商品卡片
                  const _ProductCard(),
                ],
              ),
            ),
            const SizedBox(width: 12), // 左右列间距透出 home 背景色 (#213775)
            // 右侧列：模块 3（商品卡片） + 模块 4（商品卡片）
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // 模块 3：右侧上方商品卡片
                  _ProductCard(),
                  SizedBox(height: 12), // 上下间距透出 home 背景色 (#213775)
                  // 模块 4：右侧下方商品卡片
                  _ProductCard(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // 底部居中的 bottom.png (67x20) 及下箭头 (12x7)，整体水平居中
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/home/bottom.png',
                width: 67,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              SizedBox(width: 24, height: 14, child: const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 商品图片：hotproduct.png，圆角 9dp
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/images/home/hotproduct.png',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 会员价标签 + 商品名称（3行）
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4, bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF213775), // 同 Home 藏青色背景 #213775
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      '会员价 ￥700',
                      style: TextStyle(
                        color: Color(0xFFD7B480), // 金色文字
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: '天佑德电商专供青稞酒特别版本42度500ml',
                  style: TextStyle(color: Color(0xFF000000), fontSize: 11, height: 1.25),
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // 标签行：52%vol, 清香型
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('52%vol', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 9)),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('清香型', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 9)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 价格与购物车行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '￥',
                    style: TextStyle(color: Color(0xFFFF2105), fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    '800',
                    style: TextStyle(color: Color(0xFFFF2105), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '¥985',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 9, decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/home/cart_red.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_cart, size: 16, color: Color(0xFFFF2105)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
