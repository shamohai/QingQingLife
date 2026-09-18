import 'package:flutter/material.dart';

import '../../data/models/service_product_detail_model.dart';

/// 积分商城服务商品详情 — Hero 区域
///
/// 包含真实设计背景图、半透明返回胶囊按钮（使用设计稿 PNG 图标），
/// 以及底部渐变遮罩过渡。
class HeroSection extends StatelessWidget {
  final ServiceProductDetail product;
  final VoidCallback onBack;

  const HeroSection({super.key, required this.product, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. 真实设计背景图（full-bleed，覆盖整个 Hero 区域）
        SizedBox(
          height: 389,
          child: Image.asset(
            'assets/images/service/service_product_hero_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        // 2. 状态栏（模拟）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                const Text(
                  '9:41',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
                ),
                const Spacer(),
                // 信号/电池图标行
                const Text('􀙇', style: TextStyle(fontSize: 14, color: Color(0xFF1F2024))),
                const SizedBox(width: 12),
                const Text('􀛨', style: TextStyle(fontSize: 17, color: Color(0xFF1F2024))),
              ],
            ),
          ),
        ),

        // 3. 返回胶囊按钮
        Positioned(
          top: statusBarHeight + 50,
          left: 24,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 106,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x4D000000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/service/icon_back_detail.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '商品详情',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 4. 底部渐变遮罩：平滑过渡到白色卡片区域
        Positioned(
          left: 0,
          right: 0,
          bottom: -30,
          height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x0D000000), Color(0xFFF3F5F7)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
