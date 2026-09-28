import 'package:flutter/material.dart';

/// 积分商城服务商品详情 — 固定底部操作栏
///
/// 深蓝色渐变胶囊按钮，固定在页面底部，不随滚动移动。
/// 尺寸严格按设计稿归一化：bar 71px，CTA 337×42px。
class BottomActionBar extends StatelessWidget {
  final VoidCallback onExchange;

  const BottomActionBar({super.key, required this.onExchange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Center(
          child: GestureDetector(
            onTap: onExchange,
            child: Container(
              width: 337,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]),
              ),
              child: const Center(
                child: Text(
                  '立即兑换',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
