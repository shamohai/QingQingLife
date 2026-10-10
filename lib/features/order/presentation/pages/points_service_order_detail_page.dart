import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_detail_provider.dart';

/// 积分订单详情页（服务商品无加购 - lanhu_wodequanbudingdanjifendingdanxiangqingfuwushangpin）
class PointsServiceOrderDetailPage extends ConsumerWidget {
  final String orderId;

  const PointsServiceOrderDetailPage({super.key, required this.orderId});

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
      body: asyncDetail.when(
        data: (response) {
          if (!response.success || response.data == null) {
            return const Center(child: Text('订单不存在'));
          }
          return _PointsServiceOrderBody(detail: response.data!);
        },
        loading: () => const Center(child: AppLoading()),
        error: (err, stack) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _PointsServiceOrderBody extends StatelessWidget {
  final OrderDetail detail;

  const _PointsServiceOrderBody({required this.detail});

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
                  // 页面双渐变背景 (同 orders/3：上 65% / 下 35% 带底图)
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

                  // 前景内容区 (参考 orders/1，去掉底部加购模块)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        // 交易状态 Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(26, 12, 14, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/order/huaban.png',
                                width: 36,
                                height: 36,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF213775)),
                              ),
                              Text(
                                detail.statusText.isNotEmpty ? detail.statusText : '交易完成',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // 1. 服务项目主卡片
                        Transform.translate(
                          offset: const Offset(0, -15),
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
                                              const Row(children: [_Tag('旅游券'), SizedBox(width: 8), _Tag('三日游')]),
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

                                  // 订单元数据信息
                                  _MetaRow(label: '服务订单编号', value: detail.orderNo),
                                  const SizedBox(height: 8),
                                  _MetaRow(label: '订单类型', value: '积分订单'),
                                  const SizedBox(height: 8),
                                  _MetaRow(label: '兑换时间', value: _formatDate(detail.createTime)),
                                  const SizedBox(height: 8),
                                  _MetaRow(label: '订单备注', value: '无备注'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. 专属管家二维码卡片
                        Transform.translate(
                          offset: const Offset(0, -5),
                          child: Padding(
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
