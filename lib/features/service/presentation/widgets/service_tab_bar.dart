import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 服务中心顶部 Tab 栏
///
/// 4 个固定分类，等分宽度，选中项底部蓝色下划线，未选中项灰色。
/// 不使用 Material TabBar，以保持与设计稿一致的视觉样式。
class ServiceTabBar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const ServiceTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  static const _tabKeys = ['golf', 'zhiyouhui', 'huodong', 'goujiu'];
  static const _tabLabels = ['服务预约', '挚友报名会', '活动报名', '购酒享服务'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _tabKeys.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xl),
        itemBuilder: (context, index) {
          final tabKey = _tabKeys[index];
          final tabLabel = _tabLabels[index];
          final isSelected = selectedTab == tabKey;
          return GestureDetector(
            onTap: () => onTabChanged(tabKey),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.serviceTabActive : AppColors.serviceTabInactive,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (isSelected)
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.serviceTabActive,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

