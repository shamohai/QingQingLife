import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../domain/models/notification_models.dart';

/// 通知类型入口（顶部横向类型栏）
///
/// 数据完全来自接口 getnotificationtypestat：
///   icon → 类型图标、typename → 类型名称、type → tab 身份与点击后拉取列表的筛选值、unreadcount → 角标。
///
/// 选中态（柔和）：图标底部一层浅色圆形光晕背景 + 名称主题色加粗；无边框、无整卡背景。
///
/// 接口未下发 icon 时，使用通用通知图标占位，避免出现空白块。
class NotificationTypeTabs extends StatelessWidget {
  /// 当前选中的接口 type 数值；null 表示「全部」
  final int? selected;

  /// 类型统计（顺序与内容均由后端下发）
  final List<NotificationTypeStat> stats;

  /// 点击回调，参数为该 tab 接口下发的原始 type 数值
  final ValueChanged<int?> onSelect;

  const NotificationTypeTabs({super.key, required this.selected, required this.stats, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final stat in stats) _TypeTab(stat: stat, isSelected: selected == stat.typeValue, onTap: () => onSelect(stat.typeValue))],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final NotificationTypeStat stat;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({required this.stat, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 选中态：图标下柔和圆形光晕（浅色阴影背景，替代整卡高亮）
                  if (isSelected)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.65),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF24427A).withValues(alpha: 0.14), blurRadius: 10, spreadRadius: 2),
                              BoxShadow(color: Colors.white.withValues(alpha: 0.9), blurRadius: 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Center(child: _buildIcon()),
                  if (stat.unreadCount > 0) Positioned(top: 0, right: 0, child: _buildBadge()),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF24427A) : const Color(0xFF8B9AB4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 类型图标：优先使用接口 icon，缺失或加载失败时用通用通知图标占位
  Widget _buildIcon() {
    if (stat.icon.trim().isEmpty) return _buildPlaceholderIcon();

    return AppNetworkImage(url: stat.icon, width: 44, height: 44, fit: BoxFit.contain, errorWidget: _buildPlaceholderIcon());
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.notifications_rounded, size: 44, color: Color(0xFF2E7BE8));
  }

  /// 未读角标（> 99 展示 99+）
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      constraints: const BoxConstraints(minWidth: 15),
      decoration: BoxDecoration(color: const Color(0xFFE02E2A), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(
        stat.unreadCount > 99 ? '99+' : '${stat.unreadCount}',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
      ),
    );
  }
}
