import 'package:flutter/material.dart';

/// 统一确认弹窗
class AppDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}