import 'package:flutter/material.dart';

/// 统一底部面板
class AppBottomSheet {
  static void show({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          child,
        ],
      ),
    );
  }
}