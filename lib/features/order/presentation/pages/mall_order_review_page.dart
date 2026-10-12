import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/order_detail_provider.dart';

/// 商城订单评价页（lanhu_wodequanbudingdanshangchengdingdanxiangqingdaipingjia）
class MallOrderReviewPage extends ConsumerStatefulWidget {
  final String orderId;

  const MallOrderReviewPage({super.key, required this.orderId});

  @override
  ConsumerState<MallOrderReviewPage> createState() => _MallOrderReviewPageState();
}

class _MallOrderReviewPageState extends ConsumerState<MallOrderReviewPage> {
  final List<bool> _starSelected = [false, false, false, false, false];
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(mockOrderDetailByIdProvider(widget.orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '评价',
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
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('评价提交成功')));
                    context.pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3152AF), Color(0xFF213775)]),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Center(
                      child: Text(
                        '确认提交',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: asyncDetail.when(
        data: (response) {
          if (!response.success || response.data == null) {
            return const Center(child: Text('订单不存在'));
          }
          final detail = response.data!;
          final firstItem = detail.items.isNotEmpty ? detail.items.first : null;

          return Stack(
            children: [
              // 顶部渐变背景（从导航栏延伸至中间，参考 orders/7）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 250,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0E8FF), Color(0xFFF3F5F7)]),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 商品信息卡片
                    if (firstItem != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(
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
                      ),
                    ],

                    const SizedBox(height: 12),

                    // 2. 商品评分卡片
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Text(
                            '商品评分',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _starSelected[index] = !_starSelected[index]),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Image.asset(
                                    _starSelected[index] ? 'assets/images/order/redstar.png' : 'assets/images/order/star.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. 商品评价输入与上传图片卡片
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '商品评价',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _textController,
                            maxLines: 12,
                            // maxLength: 200,
                            decoration: const InputDecoration(
                              hintText: '请输入商品评价',
                              hintStyle: TextStyle(fontSize: 14, color: Color(0xFFC4C4C9)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              counterStyle: TextStyle(color: Color(0xFF8E8E97)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('选择图片')));
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F5F7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE1E4DC)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 28, color: Color(0xFF8E8E97)),
                                  SizedBox(height: 4),
                                  Text('上传图片', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E97))),
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
            ],
          );
        },
        loading: () => const Center(child: AppLoading()),
        error: (err, stack) => const Center(child: Text('加载失败')),
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
