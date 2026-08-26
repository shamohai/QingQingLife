import 'package:flutter/material.dart';

import '../models/update_info.dart';

/// 更新弹窗 Widget
///
/// - force：强制更新，禁止返回键关闭
/// - suggest：建议更新，允许取消
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.info, this.onConfirm});

  final UpdateInfo info;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    if (info.isForceUpdate) return _ForceDialog(info: info, onConfirm: onConfirm);
    return _SuggestDialog(info: info, onConfirm: onConfirm);
  }
}

class _ForceDialog extends StatelessWidget {
  const _ForceDialog({required this.info, this.onConfirm});
  final UpdateInfo info;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {},
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('发现新版本',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              SelectableText(info.updateContent,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('立即更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestDialog extends StatelessWidget {
  const _SuggestDialog({required this.info, this.onConfirm});
  final UpdateInfo info;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: SelectableText(info.updateContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('稍后再说'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: const Text('立即更新'),
        ),
      ],
    );
  }
}
