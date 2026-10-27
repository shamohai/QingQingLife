import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../data/models/carousel_model.dart';
import '../../../../core/widgets/app_image.dart';

/// 金刚区：10格图标导航（2行5列），白色卡片容器
/// 设计稿：66x66 图标 + 14px 黑色文字，16px 水平间距
class HomeKingKongGrid extends StatelessWidget {
  final List<HomeKingKongItem> items;

  const HomeKingKongGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      // 去掉 height，依靠内边距和网格内容自然撑高
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(14))),
      child: GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        childAspectRatio: 0.83, // <-- 调整为 0.83，正好贴合 64px 的内容高度
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: List.generate(items.length > 10 ? 10 : items.length, (i) => _KingKongItem(item: items[i])),
      ),
    );
  }
}

class _KingKongItem extends StatelessWidget {
  final HomeKingKongItem item;
  const _KingKongItem({required this.item});

  void _handleTap(BuildContext context) {
    // 金刚区当前统一进入积分商城全部商品页；后续可在此处追加分类参数。
    context.push(RouteNames.allProducts);
    return;

    final actionUrl = item.actionUrl ?? '';
    switch (item.jumpType) {
      case JumpType.productDetail:
        if (actionUrl.isNotEmpty) {
          context.push(RouteNames.productDetail.replaceFirst(':id', actionUrl));
        }
        break;
      case JumpType.creditMall:
        context.push(RouteNames.pointsMall);
        break;
      case JumpType.cart:
        context.push(RouteNames.cart);
        break;
      case JumpType.orderList:
        context.push(RouteNames.orders);
        break;
      case JumpType.productList:
      case JumpType.programPage:
      case JumpType.zjProgramPage:
      case JumpType.webView:
        if (actionUrl.isNotEmpty) {
          if (actionUrl.startsWith('/pages/mall/index') || actionUrl.startsWith('/shop')) {
            context.go(RouteNames.shop);
          } else if (actionUrl.startsWith('/points')) {
            context.go(RouteNames.points);
          } else if (actionUrl.startsWith('/home')) {
            context.go(RouteNames.home);
          } else if (actionUrl.startsWith('/')) {
            context.push(actionUrl);
          } else {
            final uri = Uri.tryParse(actionUrl);
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        }
        break;
      case JumpType.none:
      default:
        if (actionUrl.isNotEmpty) {
          if (actionUrl.startsWith('/pages/mall/index') || actionUrl.startsWith('/shop')) {
            context.go(RouteNames.shop);
          } else if (actionUrl.startsWith('/points')) {
            context.go(RouteNames.points);
          } else if (actionUrl.startsWith('/home')) {
            context.go(RouteNames.home);
          } else if (actionUrl.startsWith('/')) {
            context.push(actionUrl);
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44, // 44x44 图标尺寸，为 5 列网格和文字保留充足空间
            height: 44,
            child: item.iconUrl.isNotEmpty
                ? AppNetworkImage(url: item.iconUrl, fit: BoxFit.contain, memCacheWidth: 88, memCacheHeight: 88)
                : Container(
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: const Center(child: Icon(Icons.category_outlined, size: 24, color: Colors.grey)),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12, // 设计稿 12px 标准标签字号
              color: const Color(0xFF1A1D1C), // 设计稿黑色文字
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
