import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';

/// 服务订单详情页（基于蓝湖设计稿 lanhu_wodequanbudingdanfuwudingdanxiangqing 还原）
class ServiceOrderDetailPage extends ConsumerWidget {
  final String orderId;

  const ServiceOrderDetailPage({super.key, required this.orderId});

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
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncDetail.when(
        data: (response) {
          if (!response.success || response.data == null) {
            return const Center(child: Text('订单不存在'));
          }
          return _ServiceOrderBody(detail: response.data!);
        },
        loading: () => const Center(child: AppLoading()),
        error: (err, stack) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _ServiceOrderBody extends StatelessWidget {
  final OrderDetail detail;

  const _ServiceOrderBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final firstItem = detail.items.isNotEmpty ? detail.items.first : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        children: [
          // 交易状态 Banner（顶部连接 #E0E8FF，向下渐变至背景色 #F3F5F7）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0E8FF), Color(0xFFF3F5F7)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 26),
                Image.asset(
                  'assets/images/order/huaban.png',
                  width: 46,
                  height: 46,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_rounded, size: 46, color: Color(0xFF213775)),
                ),
                //const SizedBox(width: 12),
                Text(
                  detail.statusText.isNotEmpty ? detail.statusText : '交易完成',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 1. 服务项目主卡片
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 服务信息 Row
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
                              // 标签行
                              const Row(children: [_Tag('购酒送服务'), SizedBox(width: 8), _Tag('服务套餐')]),
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

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: SizedBox(height: 1),
                    //Divider(height: 1, color: Color(0xFFE1E4DC)),
                  ),

                  // 金额细项
                  _AmountRow(label: '商品总价', value: '¥${(detail.productTotalCents / 100).toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _AmountRow(label: '总计金额', value: '¥${(detail.payAmountCents / 100).toStringAsFixed(2)}', isTotal: true),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE1E4DC)),
                  ),

                  // 订单元数据信息
                  _MetaRow(label: '服务订单编号', value: detail.orderNo),
                  const SizedBox(height: 8),
                  _MetaRow(label: '订单类型', value: '服务订单'),
                  const SizedBox(height: 8),
                  _MetaRow(label: '下单时间', value: _formatDate(detail.createTime)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. 专属管家二维码卡片
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  const Text(
                    '长按保存二维码  添加您的专属管家',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/order/butler_qr.png',
                    width: 153,
                    height: 153,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 153,
                      height: 153,
                      color: const Color(0xFFF3F5F7),
                      child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0xFF213775)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. 加购产品明细卡片
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '加购产品明细',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(height: 12),

                  // 列表项 1
                  const _UpsellProductItem(),
                  const SizedBox(height: 12),

                  // 列表项 2
                  const _UpsellProductItem(),
                  const SizedBox(height: 16),

                  // 查看更多按钮
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '点击查看更多',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8E8E97)),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF8E8E97)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

// ── 辅助小组件 ─────────────────────────────────────────────────────────────

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
            fontSize: isTotal ? 16 : 14,
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

class _UpsellProductItem extends StatelessWidget {
  const _UpsellProductItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 商品图片与自营标签
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppNetworkImage(url: 'assets/images/product/product1.jpg', width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2, right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFF213775), borderRadius: BorderRadius.circular(2)),
                    child: const Text('自营', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  const Expanded(
                    child: Text(
                      '天佑德电商专供青稞酒特别版本42度500ml',
                      style: TextStyle(fontSize: 16, color: Colors.black, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '￥800',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
