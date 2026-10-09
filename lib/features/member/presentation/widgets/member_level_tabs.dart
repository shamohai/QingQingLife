import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/member_level_provider.dart';

/// 会员详情页 - 等级页签（横向滚动）
///
/// 设计稿：人之德/家之德/国之德/天之德/顾问级，
/// 选中项白字加粗 + 白色短横线指示，未选中项半透明白字。
class MemberLevelTabs extends StatelessWidget {
  final List<MemberLevelOption> levels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const MemberLevelTabs({super.key, required this.levels, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  levels[index].name,
                  style: TextStyle(
                    fontSize: selected ? 15 : 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? Colors.white : const Color(0xCCFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: 3,
                  decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
