import 'package:flutter/material.dart';

/// 全部商品页面搜索栏（白色胶囊 pill，蓝色描边）
///
/// 设计稿规格：h=39, w=280, borderRadius=999, border=1px solid #213775
/// 左侧蓝色圆点指示器（16×16px），placeholder "搜索心仪好物"，右侧"搜索"文字
class AllProductsSearchBar extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearch;

  const AllProductsSearchBar({super.key, this.searchController, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF213775), width: 1),
      ),
      child: Row(
        children: [
          // 搜索图标
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 20, color: Color(0xFF213775)),
          // placeholder 文字区域
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(fontSize: 14),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: '搜索心仪好物',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF949599)),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hoverColor: Colors.white,
                focusColor: Colors.white,
                fillColor: Colors.white,
                filled: true,
              ),
              onSubmitted: (value) => onSearch?.call(value),
            ),
          ),
          const SizedBox(width: 4),
          // 搜索按钮
          GestureDetector(
            onTap: () => onSearch?.call(searchController?.text ?? ''),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '搜索',
                style: TextStyle(fontSize: 14, color: Color(0xFF213775), fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
