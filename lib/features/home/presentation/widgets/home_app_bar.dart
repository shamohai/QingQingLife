import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

/// 首页顶部栏：蓝湖设计稿精确样式
/// - 白色圆角胶囊搜索框（1px #213775 边框，圆角胶囊）：
///   - 内部左侧：搜索图标 + 提示文字 "天之德"
///   - 内部右侧：深蓝色 "搜索" 文本按钮 (#213775)
/// - 右侧边框外：通知小铃铛图标
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final VoidCallback? onMessagesTap;
  final ValueChanged<String>? onSearch;

  const HomeAppBar({super.key, this.searchController, this.onMessagesTap, this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF213775), // 设计稿藏青底色 #213775
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // 胶囊搜索框 (1px #213775 边框，白色背景)
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF213775), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      // 内部左侧：搜索图标
                      const Icon(Icons.search, size: 18, color: Color(0xFF999999)),
                      const SizedBox(width: 6),
                      // 内部提示文字 "天之德" / 输入框
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onSubmitted: onSearch,
                          decoration: InputDecoration(
                            hintText: '天之德',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF999999), fontSize: 13),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none, // 建议补上
                            focusedBorder: InputBorder.none, // 建议补上
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                        ),
                      ),
                      // 内部右侧："搜索" 文本 (#213775)
                      GestureDetector(
                        onTap: () {
                          if (onSearch != null) {
                            onSearch!(searchController?.text ?? '天之德');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '搜索',
                            style: const TextStyle(color: Color(0xFF213775), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 右侧边框外：通知小铃铛
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 24, color: Colors.white),
                onPressed: onMessagesTap,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
