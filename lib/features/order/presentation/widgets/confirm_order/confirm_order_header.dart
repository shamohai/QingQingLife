import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../member/domain/repositories/member_repository.dart';

/// 确认订单页顶部：返回按钮 + 收货地址信息。
class MallConfirmOrderHeader extends StatelessWidget {
  const MallConfirmOrderHeader({super.key, required this.address, required this.onEditAddress});

  final MemberAddress address;
  final VoidCallback onEditAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 153,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6, bottom: 17),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 27,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Image.asset('assets/images/order/confirm-order-back.png', width: 24, height: 24)),
                  const Text(
                    '确认订单',
                    style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 21,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Image.asset('assets/images/points/confirm_order_location.png', width: 17, height: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${address.province} ${address.city} ${address.district} 建兰路街道',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF8E8E93)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 27,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      address.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEditAddress,
                    child: const Text('修改地址>', style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF213775))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 21,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text('${address.name}   ${address.phone}', style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
