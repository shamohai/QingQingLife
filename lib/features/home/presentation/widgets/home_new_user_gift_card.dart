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
                Image.asset(
                  'assets/images/home/kingkong_member.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                    child: const Icon(Icons.card_giftcard, size: 10, color: Colors.white),
                  ),
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
        // 优惠券卡片横向可滑动列表 (卡片统一等宽 112px，左右可滑动)
        if (gifts.isEmpty)
          const Text('暂无新人礼', style: AppTextStyles.bodySmall)
        else
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: gifts.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 112, // 统一固定的卡片宽度，保证全部完全等宽
                  child: _CouponTicketCard(gift: gifts[index], index: index),
                );
              },
            ),
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
    final isSoldOut = index == 2;
    final buttonText = isSoldOut ? '已抢光' : (index == 1 ? '去使用' : '立即领取');

    // 解析金额与标签
    String amount = '20';
    String label = gift.desc ?? '新人优惠券';
    if (gift.title.contains('减')) {
      final parts = gift.title.split('减');
      amount = parts.length > 1 ? parts[1] : gift.title;
    } else {
      amount = gift.title.replaceAll(RegExp(r'[^\d.]'), '');
      if (amount.isEmpty) amount = '20';
    }

    // 根据蓝湖 XML 规范配置 3 种按钮样式与边框圆角 (3dp)
    BoxDecoration buttonDecoration;
    Color buttonTextColor;

    if (isSoldOut) {
      // 已抢光样式: 1dp #66fb9126 边框, 3dp 圆角, #66fb9126 文字
      buttonDecoration = BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0x66FB9126), width: 1),
        borderRadius: BorderRadius.circular(3),
      );
      buttonTextColor = const Color(0x66FB9126);
    } else if (index == 1) {
      // 去使用样式: 1dp #fffb9126 边框, 3dp 圆角, #fffb9126 文字
      buttonDecoration = BoxDecoration(
        color: Colors.white.withAlpha(200),
        border: Border.all(color: const Color(0xFFFB9126), width: 1),
        borderRadius: BorderRadius.circular(3),
      );
      buttonTextColor = const Color(0xFFFB9126);
    } else {
      // 立即领取样式: 实心 #fffb9126 填充, 3dp 圆角, #ffffff 文字
      buttonDecoration = BoxDecoration(
        color: const Color(0xFFFB9126),
        borderRadius: BorderRadius.circular(3),
      );
      buttonTextColor = Colors.white;
    }

    return Container(
      height: 116, // 设计稿 116px 高度
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图: kingkong_region.png
            Image.asset(
              'assets/images/home/kingkong_region.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFFFF7F0),
              ),
            ),
            // 卡片内部文字与按钮布局
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 金额与描述
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF542A00), // #ff542a00 金额颜色
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF542A00), // #ff542a00 金额颜色
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFB9126), // #fffb9126 描述颜色
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // 蓝湖样式分割线: 43dp 宽, 1dp 高, 颜色 #fff1beb2
                  Container(
                    width: 43,
                    height: 1,
                    color: const Color(0xFFF1BEB2),
                  ),
                  // 底部按钮
                  Container(
                    width: double.infinity,
                    height: 22,
                    decoration: buttonDecoration,
                    child: Center(
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: buttonTextColor,
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
    );
  }
}
