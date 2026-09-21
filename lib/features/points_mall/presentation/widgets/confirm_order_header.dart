import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';

/// 确认订单顶部地址卡片
class ConfirmOrderHeader extends StatelessWidget {
  const ConfirmOrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回行
          Padding(
            padding: const EdgeInsets.only(top: 6, left: AppSpacing.lg),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset('assets/images/points/confirm_order_back.png', width: 24, height: 24),
                ),
                const SizedBox(width: 4),
                const Text(
                  '确认订单',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                ),
              ],
            ),
          ),
          // 省市区（带定位图标）
          Padding(
            padding: const EdgeInsets.only(top: 30, left: AppSpacing.xxl),
            child: Row(
              children: [
                Image.asset('assets/images/points/confirm_order_location.png', width: 14, height: 14),
                const SizedBox(width: 4),
                const Text(
                  '甘肃省 兰州市 七里河区 建兰路街道',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                ),
              ],
            ),
          ),
          // 详细地址 + 修改地址
          Padding(
            padding: const EdgeInsets.only(top: 4, left: AppSpacing.xxl),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '兰州中心办公楼801室',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '修改地址>',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          // 联系人
          Padding(
            padding: const EdgeInsets.only(top: 4, left: AppSpacing.xxl, bottom: 17),
            child: const Text(
              '吴彦祖　130 9876 9987',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
            ),
          ),
        ],
      ),
    );
  }
}
