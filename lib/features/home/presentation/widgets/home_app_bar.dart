import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

/// 首页顶部栏：设计稿样式 - 包含 Logo、搜索框、消息按钮
/// 注意：设计稿截图顶部的设备状态栏（时间、信号、WiFi、电量）为 mockup 占位，非页面实际内容
/// 真机上由系统状态栏显示，此处不再渲染模拟状态栏
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onMessagesTap;
  final ValueChanged<String>? onSearch;

  const HomeAppBar({super.key, this.searchController, this.onMessagesTap, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF213775), // 设计稿深蓝背景
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // 设计稿 14px 边距
          child: Row(
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
        ),
      ),
    );
  }
}
