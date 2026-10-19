import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';

/// 常用功能宫格（4 列 × 2 行）
///
/// 描边风格图标 + 文字标签，点击跳转至对应路由
/// （部分页面暂未实现，保留 debugPrint 与 TODO）。
class ProfileFeatureGrid extends StatelessWidget {
  const ProfileFeatureGrid({super.key});

  static const List<_FeatureItem> _items = [
    _FeatureItem(icon: Icons.photo_camera_outlined, label: '预约报名', route: null),
    _FeatureItem(icon: Icons.diamond_outlined, label: '我的权益', route: RouteNames.memberLevel),
    _FeatureItem(icon: Icons.person_outline, label: '个人信息', route: RouteNames.personalInfo),
    _FeatureItem(icon: Icons.location_on_outlined, label: '收货地址', route: RouteNames.address),
    _FeatureItem(icon: Icons.phone_outlined, label: '联系客服', route: RouteNames.customerService),
    _FeatureItem(icon: Icons.receipt_long_outlined, label: '发票中心', route: RouteNames.invoiceCenter),
    _FeatureItem(icon: Icons.verified_user_outlined, label: '账号安全', route: null),
    _FeatureItem(icon: Icons.domain_outlined, label: '关于我们', route: RouteNames.aboutUs),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '常用功能',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C)),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            mainAxisSpacing: AppSpacing.lg,
            children: _items.map((item) => _FeatureGridItem(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final String? route;

  const _FeatureItem({required this.icon, required this.label, required this.route});
}

class _FeatureGridItem extends StatelessWidget {
  final _FeatureItem item;

  const _FeatureGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.route != null) {
          context.push(item.route!);
        } else {
          debugPrint('[ProfileFeatureGrid] 路由未实现: ${item.label}');
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 30, color: const Color(0xFF1A1D1C)),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
