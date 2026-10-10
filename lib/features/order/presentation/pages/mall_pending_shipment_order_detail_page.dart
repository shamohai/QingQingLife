import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';

/// 商城订单详情页（待发货 - lanhu_wodequanbudingdanshangchengdingdanxiangqingdaifahuo）
class MallPendingShipmentOrderDetailPage extends ConsumerWidget {
  final String orderId;

  const MallPendingShipmentOrderDetailPage({super.key, required this.orderId});

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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(999)),
                    child: const Text(
                      '申请退款',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(999)),
                    child: const Text(
                      '修改地址',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
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
          return _MallPendingShipmentOrderBody(detail: response.data!);
        },
        loading: () => const Center(child: AppLoading()),
        error: (err, stack) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _MallPendingShipmentOrderBody extends StatelessWidget {
  final OrderDetail detail;

  const _MallPendingShipmentOrderBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final firstItem = detail.items.isNotEmpty ? detail.items.first : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          // 待发货状态 Banner
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0E8FF), Color(0xFFF3F5F7)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(26, 12, 14, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/order/huaban.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.access_time_rounded, size: 36, color: Color(0xFF213775)),
                ),
                const SizedBox(width: 12),
                Text(
                  detail.statusText.isNotEmpty ? detail.statusText : '待发货',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
          ),

          // 1. 地址信息卡片（同 orders/3：第一行图标+省市区同行，右侧修改地址垂直居中）
          Transform.translate(
            offset: const Offset(0, -15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF213775)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${detail.address.province} ${detail.address.city} ${detail.address.district} 建兰路街道',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97), height: 1.3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            detail.address.detail,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text('${detail.address.name}   ${detail.address.phone}', style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E97))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '修改地址>',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF213775)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. 商城商品与订单详情全能卡片
          Transform.translate(
            offset: const Offset(0, -5),
            child: Padding(
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
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                  children: [
                                    const TextSpan(text: '¥', style: TextStyle(fontSize: 12)),
                                    TextSpan(text: '${(firstItem.totalCents / 100).toInt()}', style: const TextStyle(fontSize: 16)),
                                    const TextSpan(text: '.00', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('×${firstItem.quantity}', style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E97))),
                            ],
                          ),
                        ],
                      ),
                    ],

                    const Padding(padding: EdgeInsets.symmetric(vertical: 3), child: SizedBox(height: 1)),

                    // 费用明细
                    _AmountRow(label: '商品总价', value: '¥${(detail.productTotalCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _AmountRow(label: '订单运费', value: '¥${(detail.shippingFeeCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _AmountRow(label: '优惠券抵扣', value: '-¥${(detail.discountCents / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _AmountRow(label: '总计金额', value: '¥${(detail.payAmountCents / 100).toStringAsFixed(2)}', isTotal: true),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFE1E4DC)),
                    ),

                    // 商城订单元数据信息
                    _MetaRow(label: '商城订单编号', value: detail.orderNo),
                    const SizedBox(height: 8),
                    _MetaRow(label: '交易单号', value: 'JYDH345678678654678976'),
                    const SizedBox(height: 8),
                    _MetaRow(label: '支付方式', value: '微信支付'),
                    const SizedBox(height: 8),
                    _MetaRow(label: '订单类型', value: '商城订单'),
                    const SizedBox(height: 8),
                    _MetaRow(label: '下单时间', value: _formatDate(detail.createTime)),
                    const SizedBox(height: 8),
                    _MetaRow(label: '付款时间', value: _formatDate(detail.payTime ?? detail.createTime)),
                    const SizedBox(height: 8),
                    _MetaRow(label: '订单备注', value: '请尽快发货，打算朋友生日送礼！'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
          style: TextStyle(fontSize: isTotal ? 16 : 16, fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400, color: isTotal ? const Color(0xFFFF2105) : Colors.black),
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
