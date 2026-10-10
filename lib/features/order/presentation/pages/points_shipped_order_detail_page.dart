import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';

/// 积分订单详情页（待收货/待核销 - lanhu_wodequanbudingdanjifendingdanxiangqingshiwushangpindaishouhuo）
class PointsShippedOrderDetailPage extends ConsumerWidget {
  final String orderId;

  const PointsShippedOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(mockOrderDetailByIdProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '订单详情',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -1))],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: 53,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(999)),
                    child: const Text(
                      '修改地址',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF213775), borderRadius: BorderRadius.circular(999)),
                    child: const Text(
                      '确认收货',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: asyncDetail.when(
        data: (response) {
          if (!response.success || response.data == null) {
            return const Center(child: Text('订单不存在'));
          }
          return _PointsShippedOrderBody(detail: response.data!);
        },
        loading: () => const Center(child: AppLoading()),
        error: (err, stack) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _PointsShippedOrderBody extends StatelessWidget {
  final OrderDetail detail;

  const _PointsShippedOrderBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final firstItem = detail.items.isNotEmpty ? detail.items.first : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  // 页面双渐变背景 (上半部 65% 为 #E0E8FF -> #F3F5F7，下半部 35% 为 #F3F5F7 -> #FFFFFF 并延伸到底部导航栏)
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 55,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0E8FF), Color(0xFFF3F5F7)]),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 45,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF3F5F7), Color(0xFFFFFFFF)]),
                              image: DecorationImage(
                                image: AssetImage('assets/images/order/order_bottom_bg.png'),
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 前景内容区
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // 待收货/待核销状态 Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(26, 12, 14, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/order/huaban.png',
                                width: 36,
                                height: 36,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_shipping_rounded, size: 36, color: Color(0xFF213775)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                detail.statusText.isNotEmpty ? detail.statusText : '待收货/待核销',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // 1. 物流与地址卡片 (时间轴：实心圆点、竖线、空心圆点)
                        _LogisticsCard(detail: detail),

                        const SizedBox(height: 12),

                        // 2. 积分商品与订单详情卡片 (一个完整的白色卡片)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (firstItem != null) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: AppNetworkImage(url: firstItem.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              firstItem.productName,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            const Row(children: [_Tag('52%vol'), SizedBox(width: 8), _Tag('清香型')]),
                                            const SizedBox(height: 8),
                                            Text(
                                              firstItem.skuName,
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97), height: 1.3),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${detail.pointsCost ?? 50}积分',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('×${firstItem.quantity}', style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],

                                const Padding(padding: EdgeInsets.symmetric(vertical: 3), child: SizedBox(height: 1)),

                                // 总计积分
                                _AmountRow(label: '总计积分', value: '${detail.pointsCost ?? 50}积分', isTotal: true),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFE1E4DC)),
                                ),

                                // 元数据信息
                                _MetaRow(label: '积分订单编号', value: detail.orderNo),
                                const SizedBox(height: 8),
                                _MetaRow(label: '订单类型', value: '积分订单'),
                                const SizedBox(height: 8),
                                _MetaRow(label: '兑换时间', value: _formatDate(detail.createTime)),
                                const SizedBox(height: 8),
                                _MetaRow(label: '发货时间', value: _formatDate(detail.shipTime ?? detail.createTime)),
                                const SizedBox(height: 8),
                                _MetaRow(label: '订单备注', value: '无备注'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _LogisticsCard extends StatelessWidget {
  final OrderDetail detail;

  const _LogisticsCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：实心圆点 + 已签收 + 查看详情
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFF2105), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                const Text(
                  '已签收',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text('查看详情', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
                      Icon(Icons.chevron_right, size: 18, color: Color(0xFF8E8E97)),
                    ],
                  ),
                ),
              ],
            ),
            // 第二行：竖线 + 包裹签收说明（带拨打电话功能）
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFE9EEF3), width: 2)),
                ),
                padding: const EdgeInsets.only(left: 17.5, top: 8, bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97), height: 1.4),
                    children: [
                      const TextSpan(text: '包裹已经签收！如有疑问请联系菜鸟驿站 '),
                      TextSpan(
                        text: '183767787...',
                        style: const TextStyle(color: Color(0xFF213775), fontWeight: FontWeight.w500),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final Uri phoneUri = Uri(scheme: 'tel', path: '183767787');
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 第三行：空心圆点 + 地址信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF2105), width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detail.address.province} ${detail.address.city} ${detail.address.district} ${detail.address.detail}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black, height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text('${detail.address.name}   ${detail.address.phone}', style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF2105), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFFFF2105), fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _AmountRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? const Color(0xFFFF2105) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
      ],
    );
  }
}
