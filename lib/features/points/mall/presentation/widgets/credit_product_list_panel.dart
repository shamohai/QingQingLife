import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../../data/models/get_credit_product_list_model.dart';
import '../providers/credit_product_list_provider.dart';
import 'points_category_sidebar.dart';

/// 积分商城商品列表面板
///
/// 左侧：积分段侧边栏（可点击切换）
/// 右侧：分页商品列表（PagingListView）
class CreditProductListPanel extends ConsumerStatefulWidget {
  final int activeCategoryId;

  const CreditProductListPanel({super.key, this.activeCategoryId = 0});

  @override
  ConsumerState<CreditProductListPanel> createState() => _CreditProductListPanelState();
}

class _CreditProductListPanelState extends ConsumerState<CreditProductListPanel> {
  int _activeIndex = 0;

  void _onRangeTap(int index) {
    setState(() => _activeIndex = index);
    final notifier = ref.read(creditProductListProvider.notifier);
    notifier.setCategoryId(widget.activeCategoryId);
    notifier.setIntegralRange(kPointsRangeLabels[index]);
  }

  @override
  Widget build(BuildContext context) {
    // 注意：此 Widget 嵌套在外层可滚动视图内（PagingListView shrinkWrap + NeverScrollable）。
    // IntrinsicHeight 与 ListView/ShrinkWrappingViewport 不兼容，会触发 assertion 崩溃，
    // 原因是 ListView 的 ShrinkWrappingViewport 不支持计算 intrinsic 尺寸。
    //
    // 解决方案：移除 IntrinsicHeight，用 Stack 模拟"侧边栏背景延伸"效果：
    // - Stack 底层放一个覆盖整个区域的侧边栏背景色 Container（宽度 110px）
    // - 上层叠放真实的 Row（侧边栏 + 商品列表）
    // - 右侧白色 Container 覆盖掉右侧部分的灰色背景，左侧灰色背景自然延伸到底部
    return Stack(
      children: [
        // 底层：侧边栏背景色延伸层，覆盖整个高度（由右侧商品列表撑开）
        Positioned(left: 0, top: 0, bottom: 0, width: 110, child: ColoredBox(color: const Color(0xFFF3F5F7))),
        // 上层：真实内容 Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧积分段侧边栏
            PointsCategorySidebar(activeIndex: _activeIndex, onCategoryTap: _onRangeTap),
            // 右侧分页商品列表
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: PagingListView<CreditProductItem>(
                    provider: creditProductListProvider,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    enablePullToRefresh: false,
                    emptyWidget: const AppEmpty(message: '暂无商品'),
                    itemBuilder: (context, item, index) => _buildProductCard(context, item),
                    separatorBuilder: const SizedBox(height: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, CreditProductItem item) {
    final isService = item.isService;
    return GestureDetector(
      onTap: () =>
          GoRouter.of(context).push((isService ? RouteNames.serviceProductDetail : RouteNames.productDetail).replaceFirst(':id', item.productId.toString())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          //boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imgUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(width: 100, height: 100, color: const Color(0xFFEEEEEE)),
              ),
            ),
            const SizedBox(width: 12),
            // 商品信息
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
                            item.productName,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1D1D1F), fontWeight: FontWeight.w500, height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // if (isService)
                        //   Container(
                        //     margin: const EdgeInsets.only(left: 4),
                        //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        //     decoration: BoxDecoration(color: const Color(0x1AFF2105), borderRadius: BorderRadius.circular(4)),
                        //     child: const Text(
                        //       '服务',
                        //       style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFFF2105)),
                        //     ),
                        //   ),
                      ],
                    ),
                    // 积分 + 按钮
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${item.creditPrice}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF2105)),
                        ),
                        const Text(
                          ' 积分',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                        ),
                        const Spacer(),
                        if (isService)
                          OutlinedButton(
                            onPressed: () => GoRouter.of(context).push(RouteNames.serviceProductDetail.replaceFirst(':id', item.productId.toString())),
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
                            onPressed: () => GoRouter.of(context).push(RouteNames.productDetail.replaceFirst(':id', item.productId.toString())),
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
    );
  }
}
