import 'package:flutter/material.dart';

/// 统一底部面板
class AppBottomSheet {
  /// 显示底部面板；选择类弹层可通过返回值接收结果（弹层内 [Navigator.pop] 携带）
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
    Color? backgroundColor,
    TextStyle? titleStyle,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: titleStyle ?? Theme.of(context).textTheme.headlineSmall),
            ),
          child,
        ],
      ),
    );
  }
}
