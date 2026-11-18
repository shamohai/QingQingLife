import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../data/models/service_product_detail_model.dart';
import '../providers/service_product_detail_provider.dart';

/// 积分商城服务商品详情 — 商品图片 + 详情区域卡片
/// - 模块外框圆角：9dp
/// - 图片选区边距：6.5dp（对应设计稿外框 276dp、内部图片 263dp），圆角：7dp
/// - 内容区：调用 /api/product/getproductdetailimg 接口展示商品详情图片列表
class ProductVisualCard extends ConsumerWidget {
  final ServiceProductDetail product;

  const ProductVisualCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(productDetailImagesProvider(product.id));

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部留白（紧凑缩减）
          const SizedBox(height: 6),

          // 商品详情 + 蓝色渐变条（与下方图片左侧边缘对齐，X = 6.5dp）
          Padding(
            padding: const EdgeInsets.only(left: 6.5),
            child: SizedBox(
              width: 100,
              child: Stack(
                children: [
                  // 商品详情文字
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: const Text(
                      '商品详情',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
                    ),
                  ),
                  // 蓝色渐变条（定位在文字高度约 3/4 的位置）
                  const Positioned(
                    left: 2,
                    top: 20,
                    child: SizedBox(
                      width: 70,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0088FF), Color(0x000088FF)]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // 详情图片列表展示区域（精准还原蓝湖设计稿：边距 6.5dp，图片圆角 7dp）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.5),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.zero,
                child: imagesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: AppLoading()),
                  ),
                  error: (error, stack) => _buildFallbackContent(),
                  data: (images) {
                    if (images.isNotEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: images
                            .map(
                              (url) => AppNetworkImage(
                                url: url,
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                              ),
                            )
                            .toList(),
                      );
                    }
                    return _buildFallbackContent();
                  },
                ),
              ),
            ),
          ),

          // 底部留白（紧凑缩减）
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildFallbackContent() {
    if (product.description.trim().isNotEmpty) {
      return HtmlWidget(
        product.description,
        textStyle: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6),
        customStylesBuilder: (element) {
          if (element.localName == 'img') {
            return {'width': '100%', 'height': 'auto'};
          }
          return null;
        },
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '暂无商品详情',
          style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
        ),
      ),
    );
  }
}

