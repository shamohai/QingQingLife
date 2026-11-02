import 'package:flutter/material.dart';

/// 未拥有会员权益时叠在图标底部的锁定标识。
///
/// 设计稿中的胶囊包含锁和等级文案；当前需求只保留锁，不展示 V1。
class MemberBenefitLockBadge extends StatelessWidget {
  const MemberBenefitLockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '暂无权限',
      child: Container(
        height: 16,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: const Color(0xFF1E3A6E), borderRadius: BorderRadius.circular(999)),
        alignment: Alignment.center,
        child: const Icon(Icons.lock, size: 10, color: Colors.white),
      ),
    );
  }
}
