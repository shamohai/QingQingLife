import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../models/app_update_info.dart';

/// 今日不再提醒：点击后记录当天日期，当天不再弹出
typedef OnDismissToday = Future<void> Function();

/// 原生 App 新版本提示弹窗
///
/// - 强制升级：仅保留「立即更新」，不可取消，返回键无效
/// - 非强制升级：「稍后再说」+「立即更新」，并提供「今日不再提醒」复选框
///
/// 「立即更新」跳转：iOS 打开 App Store，Android 打开下载页（均使用接口返回的 `fileurl`）。
Future<void> showAppUpdateDialog(BuildContext context, AppUpdateInfo info, {OnDismissToday? onDismissToday}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !info.isForceUpdate,
    builder: (dialogContext) => _AppUpdateDialog(info: info, onDismissToday: onDismissToday),
  );
}

class _AppUpdateDialog extends StatefulWidget {
  const _AppUpdateDialog({required this.info, this.onDismissToday});

  final AppUpdateInfo info;
  final OnDismissToday? onDismissToday;

  @override
  State<_AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<_AppUpdateDialog> {
  bool _dontRemindToday = false;

  Future<void> _onUpdatePressed() async {
    final target = _targetUrl();
    if (target == null) return;
    await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    if (!widget.info.isForceUpdate && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// iOS 跳转 App Store（未上架时 appStoreUrl 为空，返回 null，不做跳转）；Android 跳转接口返回的 fileurl。
  String? _targetUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppConfig.appStoreUrl.isEmpty ? null : AppConfig.appStoreUrl;
    }
    return widget.info.fileUrl;
  }

  Future<void> _onLaterPressed() async {
    if (_dontRemindToday) await widget.onDismissToday?.call();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final isForce = info.isForceUpdate;

    return PopScope(
      canPop: !isForce,
      child: AlertDialog(
        title: const Text('发现新版本'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.displayVersion.isNotEmpty) Text('版本：${info.displayVersion}'),
              if (info.releaseNotes.isNotEmpty) ...[const SizedBox(height: 8), Text(info.releaseNotes)],
              if (!isForce) ...[
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => setState(() => _dontRemindToday = !_dontRemindToday),
                  child: Row(
                    children: [
                      IgnorePointer(
                        child: Checkbox(value: _dontRemindToday, onChanged: (_) {}),
                      ),
                      const Text('今日不再提醒'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!isForce) ElevatedButton(onPressed: _onLaterPressed, child: const Text('稍后再说')),
          _GradientButton(label: '立即更新', onPressed: _targetUrl() == null ? null : _onUpdatePressed),
        ],
      ),
    );
  }
}

/// 与「提交订单」按钮一致的渐变胶囊按钮；尺寸与文字大小沿用默认 ElevatedButton
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white);
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(label, style: textStyle),
            ),
          ),
        ),
      ),
    );
  }
}
