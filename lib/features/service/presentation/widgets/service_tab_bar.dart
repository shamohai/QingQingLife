import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 服务中心顶部 Tab 栏
///
/// 4 个固定分类，等分宽度，选中项底部蓝色下划线，未选中项灰色。
/// 白色背景容器，底部左右角有圆角，与下方内容卡片形成视觉连贯。
class ServiceTabBar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const ServiceTabBar({super.key, required this.selectedTab, required this.onTabChanged});

  static const _tabKeys = ['fuwu', 'zhiyouhui', 'huodong', 'goujiu'];
  static const _tabLabels = ['服务预约', '挚友报名会', '活动报名', '购酒享服务'];

  @override
  Widget build(BuildContext context) {
    // 计算每个 Tab 的宽度：(屏幕宽 - 左右 padding - 分隔间距) / 4
    final screenWidth = MediaQuery.of(context).size.width;
    final totalPadding = AppSpacing.lg * 2;
    final totalSeparator = AppSpacing.md * 3;
    final tabWidth = (screenWidth - totalPadding - totalSeparator) / _tabKeys.length;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      child: Container(
        width: double.infinity,
        // 设计稿阴影：0px 2px 4px 0px rgba(0,0,0,0.1)
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _tabKeys.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final tabKey = _tabKeys[index];
              final tabLabel = _tabLabels[index];
              final isSelected = selectedTab == tabKey;
              return SizedBox(
                width: tabWidth,
                height: 44,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabChanged(tabKey),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabLabel,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          // 设计稿 fontWeight: 500 (Medium)，非 600
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? AppColors.serviceTabActive : AppColors.serviceTabInactive,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      if (isSelected)
                        // 设计稿指示条：高 6px，宽约 68px，圆角 100px
                        Container(
                          height: 6,
                          width: 68,
                          decoration: BoxDecoration(color: AppColors.serviceTabActive, borderRadius: BorderRadius.circular(AppRadius.round)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
