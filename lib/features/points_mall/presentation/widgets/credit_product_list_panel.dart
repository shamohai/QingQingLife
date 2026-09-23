import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../../../core/presentation/paging/paging_list_view.dart';
import '../../../../../core/widgets/app_empty.dart';
import '../providers/credit_product_list_provider.dart';
import '../widgets/points_category_sidebar.dart';
import '../../data/models/points_mall_home_data.dart';
import '../../data/models/get_credit_product_list_model.dart';
import '../../data/models/get_recommend_product_list_model.dart';

/// 积分商城商品列表面板
///
/// 左侧：积分段侧边栏（可点击切换）
/// 右侧：分页商品列表（PagingListView）
class CreditProductListPanel extends ConsumerStatefulWidget {
  final List<PointsRedeemGroup> groups;

  const CreditProductListPanel({super.key, required this.groups});

  @override
  ConsumerState<CreditProductListPanel> createState() => _CreditProductListPanelState();
}

class _CreditProductListPanelState extends ConsumerState<CreditProductListPanel> {
  int _activeIndex = 0;

  List<String> get _labels => ['我能兑换', ...widget.groups.map((g) => g.rangeLabel)];

  void _onRangeTap(int index) {
    setState(() => _activeIndex = index);
    final notifier = ref.read(creditProductListProvider.notifier);
    notifier.setIntegralRange(_labels[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧积分段侧边栏
        PointsCategorySidebar(
          groups: widget.groups,
          activeIndex: _activeIndex,
          onCategoryTap: _onRangeTap,
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE1E4DC)),
        // 右侧分页商品列表
        Expanded(
          child: Container(
            color: const Color(0xFFF3F5F7),
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
    );
  }

  Widget _buildProductCard(BuildContext context, CreditProductItem item) {
    final isService = _isServiceType(item.productType);
    return GestureDetector(
      onTap: isService ? () => GoRouter.of(context).push(RouteNames.serviceProductDetail.replaceFirst(':id', item.productId.toString())) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
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
                        if (isService)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0x1AFF2105), borderRadius: BorderRadius.circular(4)),
                            child: const Text('服务', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFFF2105))),
                          ),
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
                        const Text(' 积分', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFFF2105))),
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
                            child: const Text('查看', style: TextStyle(fontSize: 10, color: Color(0xFFFF2105), fontWeight: FontWeight.w500)),
                          )
                        else
                          OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('兑换商品：${item.productName}'))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF2105), width: 1),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              shape: const StadiumBorder(),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('兑换', style: TextStyle(fontSize: 10, color: Color(0xFFFF2105), fontWeight: FontWeight.w500)),
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

  bool _isServiceType(CreditProductType type) {
    return type == CreditProductType.serviceCouponIntegral || type == CreditProductType.serviceCouponSale;
  }
}
