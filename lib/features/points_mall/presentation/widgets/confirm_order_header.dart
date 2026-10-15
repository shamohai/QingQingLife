import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';

/// 确认订单顶部导航栏（使用 Flutter AppBar）
class ConfirmOrderNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const ConfirmOrderNavBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1F2024)),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '确认订单',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
      ),
    );
  }
}

/// 确认订单顶部地址卡片（导航栏 + 地址信息）
class ConfirmOrderHeader extends StatelessWidget {
  const ConfirmOrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14), // 左下圆角
              bottomRight: Radius.circular(14), // 右下圆角
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: AppSpacing.xxl),
                child: Row(
                  children: [
                    Image.asset('assets/images/points/confirm_order_location.png', width: 18, height: 18),
                    const SizedBox(width: 4),
                    const Text(
                      '甘肃省 兰州市 七里河区 建兰路街道',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                    ),
                  ],
                ),
              ),
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
              const Padding(
                padding: EdgeInsets.only(top: 4, left: AppSpacing.xxl, bottom: 17),
                child: Text(
                  '吴彦祖　130 9876 9987',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
