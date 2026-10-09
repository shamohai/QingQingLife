import 'package:flutter/material.dart';

import '../../domain/repositories/notification_repository.dart';

/// 顶部三个分类入口（系统通知 / 订单通知 / 服务通知）
///
/// 选中态：标签深色加粗；未读数 > 0 时图标右上角展示红色角标（> 99 展示 99+）。
/// TODO(资源): 设计稿 3D 图标切图未提供，暂用 Material 图标 + 渐变着色近似，切图到位后替换为 Image.asset。
class NotificationCategoryTabs extends StatelessWidget {
  final NotificationCategory selected;
  final List<NotificationCategorySummary> summaries;
  final ValueChanged<NotificationCategory> onSelect;

  const NotificationCategoryTabs({super.key, required this.selected, required this.summaries, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final category in NotificationCategory.values)
          Expanded(
            child: _CategoryTab(category: category, isSelected: category == selected, unreadCount: _unreadCountOf(category), onTap: () => onSelect(category)),
          ),
      ],
    );
  }

  int _unreadCountOf(NotificationCategory category) {
    for (final summary in summaries) {
      if (summary.category == category) return summary.unreadCount;
    }
    return 0;
  }
}

class _CategoryTab extends StatelessWidget {
  final NotificationCategory category;
  final bool isSelected;
  final int unreadCount;
  final VoidCallback onTap;

  const _CategoryTab({required this.category, required this.isSelected, required this.unreadCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: _buildIcon()),
                if (unreadCount > 0) Positioned(top: 0, right: 0, child: _buildBadge()),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF24427A) : const Color(0xFF8B9AB4),
            ),
          ),
        ],
      ),
    );
  }

  /// 分类图标（渐变着色近似设计稿 3D 图标）
  Widget _buildIcon() {
    final (IconData icon, List<Color> colors) = switch (category) {
      NotificationCategory.system => (Icons.notifications_rounded, const [Color(0xFF6FB9FF), Color(0xFF2E7BE8)]),
      NotificationCategory.order => (Icons.receipt_long_rounded, const [Color(0xFFFFB35C), Color(0xFFF0822D)]),
      NotificationCategory.service => (Icons.card_giftcard_rounded, const [Color(0xFFFF8F7E), Color(0xFFE8433B)]),
    };
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: 44, color: Colors.white),
    );
  }

  /// 未读角标
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      constraints: const BoxConstraints(minWidth: 15),
      decoration: BoxDecoration(color: const Color(0xFFE02E2A), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
      ),
    );
  }
}
