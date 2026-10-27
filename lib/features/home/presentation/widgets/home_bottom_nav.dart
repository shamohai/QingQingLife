import 'package:flutter/material.dart';

/// 底部导航栏
/// 设计稿：白色背景，80px 高度，5个 Tab（首页、商城、服务、积分、我的），选中态蓝色
class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HomeBottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // 设计稿 80px 高度
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          children: [
            _buildTabItem(0, '首页', 'assets/icon/tab_home_unselected.png', 'assets/icon/tab_home_selected.png'),
            _buildTabItem(1, '积分', 'assets/icon/tab_points_unselected.png', 'assets/icon/tab_points_selected.png'),
            // _buildTabItem(1, '商城', 'assets/icon/tab_shop_unselected.png', 'assets/icon/tab_shop_selected.png'),
            _buildTabItem(2, '服务', 'assets/icon/tab_service_unselected.png', 'assets/icon/tab_service_selected.png'),
            _buildTabItem(3, '我的', 'assets/icon/tab_profile_unselected.png', 'assets/icon/tab_profile_selected.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, String unselectedIcon, String selectedIcon) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap?.call(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? selectedIcon : unselectedIcon,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(_getDefaultIcon(index), size: 24, color: isSelected ? const Color(0xFF213775) : const Color(0xFF999999)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF213775) : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.card_giftcard_outlined;
      // case 1:
      //   return Icons.store_outlined;
      case 2:
        return Icons.miscellaneous_services_outlined;
      case 3:
        return Icons.person_outline;
      default:
        return Icons.circle_outlined;
    }
  }
}
