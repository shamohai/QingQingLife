import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../service/presentation/providers/service_provider.dart';

/// 常用功能宫格（4 列 × 2 行）
///
/// 描边风格图标 + 文字标签，点击跳转至对应路由。
/// 无路由的功能点击后不做响应。
class ProfileFeatureGrid extends StatelessWidget {
  const ProfileFeatureGrid({super.key});

  static const List<_FeatureItem> _items = [
    _FeatureItem(icon: Icons.photo_camera_outlined, label: '预约报名', route: RouteNames.service, serviceTab: 'fuwu'),
    _FeatureItem(icon: Icons.diamond_outlined, label: '我的权益', route: RouteNames.memberLevel),
    _FeatureItem(icon: Icons.person_outline, label: '个人信息', route: RouteNames.personalInfo),
    _FeatureItem(icon: Icons.location_on_outlined, label: '收货地址', route: RouteNames.address),
    _FeatureItem(icon: Icons.phone_outlined, label: '联系客服', route: RouteNames.customerService),
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
  final String? serviceTab;

  const _FeatureItem({required this.icon, required this.label, required this.route, this.serviceTab});
}

class _FeatureGridItem extends ConsumerWidget {
  final _FeatureItem item;

  const _FeatureGridItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (item.serviceTab != null) {
          ref.read(selectedTabProvider.notifier).update(item.serviceTab!);
          context.go(item.route!);
        } else if (item.route != null) {
          context.push(item.route!);
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
