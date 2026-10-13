import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

/// 首页顶部栏：设计稿样式 - 包含状态栏高度、Logo、搜索框、消息按钮
/// 总高度：50px 状态栏 + 60px 内容 = 110px（含 SafeArea 顶部）
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onMessagesTap;
  final ValueChanged<String>? onSearch;

  const HomeAppBar({super.key, this.searchController, this.onMessagesTap, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF213775), // 设计稿深蓝背景
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // 设计稿 14px 边距
          child: Column(
            children: [
              // 状态栏区域：时间、电池、信号、WiFi（白色）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Row(children: [_buildStatusIcon(Icons.signal_wifi_4_bar), const SizedBox(width: 6), _buildStatusIcon(Icons.battery_full)]),
                ],
              ),
              const SizedBox(height: 8),
              // 搜索栏行：Logo + 搜索框 + 通知铃铛
              Row(
                children: [
                  // Logo "天之德"
                  const Text(
                    '天之德',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  // 搜索框 - 白色圆角胶囊 368x40，1px #213775 边框
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF213775), width: 1),
                      ),
                      child: TextField(
                        controller: searchController,
                        onSubmitted: onSearch,
                        decoration: InputDecoration(
                          hintText: '搜索',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF999999)),
                          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 消息按钮
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24, color: Colors.white),
                    onPressed: onMessagesTap,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon) {
    return Icon(icon, size: 17, color: Colors.white);
  }
}
