import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 服务中心顶部 Tab 栏
///
/// 4 个固定分类：
/// - 宽屏：平均分配屏幕宽度
/// - 窄屏：内容自适应宽度 + 横向滚动
/// 选中项底部蓝色下划线，未选中项灰色。
/// 白色背景容器，底部左右角有圆角，与下方内容卡片形成视觉连贯。
class ServiceTabBar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const ServiceTabBar({super.key, required this.selectedTab, required this.onTabChanged});

  static const _tabKeys = ['fuwu', 'zhiyouhui', 'huodong', 'goujiu'];
  static const _tabLabels = ['服务预约', '挚友报名会', '活动报名', '购酒享服务'];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      child: Container(
        width: double.infinity,
        // 设计稿阴影：0px 2px 4px 0px rgba(0,0,0,0.1)
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.only(top: AppSpacing.lg), // xl -> lg，整体上移
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 可用宽度 = 屏幕宽 - 左右 padding
            final availableWidth = constraints.maxWidth - AppSpacing.lg * 2;
            // 每个 Tab 最小宽度 = 文字宽度 + 左右内边距
            // 预估：最长文字"购酒享服务"约 60px + 左右 16px = 76px
            // 4 个 Tab + 3 个分隔符 = 4*76 + 3*16 = 352px
            const minTabWidth = 76.0;
            const separatorWidth = AppSpacing.md; // 16
            final minTotalWidth = minTabWidth * _tabKeys.length + separatorWidth * (_tabKeys.length - 1);

            // 宽度足够：平均分配；不够：横向滚动
            final useEqualWidth = availableWidth >= minTotalWidth;

            final tabs = List<Widget>.generate(_tabKeys.length, (index) {
              final tabKey = _tabKeys[index];
              final tabLabel = _tabLabels[index];
              final isSelected = selectedTab == tabKey;

              Widget tabContent = _TabLabel(label: tabLabel, isSelected: isSelected, onTap: () => onTabChanged(tabKey));

              if (useEqualWidth) {
                // 宽屏：Expanded 平均分配
                return Expanded(child: Center(child: tabContent));
              } else {
                // 窄屏：内容自适应宽度
                return tabContent;
              }
            });

            if (useEqualWidth) {
              // 宽屏：Row 等分，无需滚动
              return SizedBox(
                height: 44,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: tabs),
              );
            } else {
              // 窄屏：ListView 横向滚动
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, index) => tabs[index],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabLabel({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中，文字整体上移
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.serviceTabActive : AppColors.serviceTabInactive,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3), // 减小文字与指示条间距：5 -> 3
            if (isSelected)
              Container(
                height: 6,
                width: 68,
                decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.round)),
              ),
          ],
        ),
      ),
    );
  }
}
