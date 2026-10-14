import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../product/domain/repositories/product_repository.dart';

/// 新人礼：优惠券卡片展示组件，对齐蓝湖设计稿
/// 设计稿：3张卡片横排，每张 116px 高，背景图 + 价格 + 标签 + 按钮
class HomeNewUserGiftCard extends StatelessWidget {
  final List<HomeNewUserGift> gifts;
  final VoidCallback? onMoreTap;

  const HomeNewUserGiftCard({super.key, required this.gifts, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Icon(Icons.card_giftcard, size: 10, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('新人礼', style: AppTextStyles.headlineSmall),
              ],
            ),
            GestureDetector(
              onTap: onMoreTap,
              child: Text('查看更多>>>', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF999999))),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // 3张优惠券卡片
        if (gifts.isEmpty)
          const Text('暂无新人礼', style: AppTextStyles.bodySmall)
        else
          Row(
            children: List.generate(gifts.length > 3 ? 3 : gifts.length, (index) {
              final gift = gifts[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < (gifts.length > 3 ? 3 : gifts.length) - 1 ? AppSpacing.sm : 0),
                  child: _CouponTicketCard(gift: gift, index: index),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _CouponTicketCard extends StatelessWidget {
  final HomeNewUserGift gift;
  final int index;

  const _CouponTicketCard({required this.gift, required this.index});

  @override
  Widget build(BuildContext context) {
    // 根据设计稿：第1张橙色填充按钮，第2张橙色描边按钮，第3张灰色描边按钮（已抢光）
    final isSoldOut = index == 2;
    final buttonText = isSoldOut ? '已抢光' : (index == 1 ? '去使用' : '立即领取');

    // 解析金额和标签
    String amount = '20';
    String label = gift.desc ?? '新人优惠券';
    if (gift.title.contains('减')) {
      final parts = gift.title.split('减');
      amount = parts.length > 1 ? parts[1] : gift.title;
    } else {
      amount = gift.title.replaceAll(RegExp(r'[^\d.]'), '');
      if (amount.isEmpty) amount = '20';
    }

    return Container(
      height: 116, // 设计稿 116px 高度
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSoldOut ? const Color(0xFFE0E0E0) : const Color(0xFFFFCDD2), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图
            Positioned.fill(
              child: Image.asset(
                'assets/images/home/topic1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ____) => Container(color: isSoldOut ? const Color(0xFFF0F0F0) : const Color(0xFFFFF0ED)),
              ),
            ),
            // 渐变遮罩
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(30)]),
                ),
              ),
            ),
            // 内容
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 价格区域 - 顶部对齐
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '¥',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSoldOut ? const Color(0xFF999999) : Colors.white),
                            ),
                            Text(
                              amount,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isSoldOut ? const Color(0xFF999999) : Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(fontSize: 11, color: isSoldOut ? const Color(0xFF999999) : Colors.white.withAlpha(200)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 底部按钮
                    Container(
                      width: double.infinity,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSoldOut ? Colors.transparent : (index == 0 ? const Color(0xFFE53935) : Colors.transparent),
                        border: Border.all(color: isSoldOut ? const Color(0xFFCCCCCC) : (index == 0 ? Colors.transparent : const Color(0xFFE53935)), width: 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSoldOut ? const Color(0xFF999999) : (index == 0 ? Colors.white : const Color(0xFFE53935)),
                          ),
                        ),
                      ),
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
