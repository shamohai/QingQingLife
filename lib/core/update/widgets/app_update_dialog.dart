import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../models/app_update_info.dart';

/// 今日不再提醒：点击后记录当天日期，当天不再弹出
typedef OnDismissToday = Future<void> Function();

/// 原生 App 新版本提示弹窗
///
/// - 强制升级：仅保留「立即更新」（整行），不可取消，返回键无效
/// - 非强制升级：「稍后再说」+「立即更新」，并提供「今日不再提醒」复选框
///
/// 「立即更新」跳转：iOS 打开 App Store（未配置时不可点击），Android 打开接口返回的 fileurl。
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
  static const _gradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]);

  bool _dontRemindToday = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 更新说明区域的高度上限：屏幕高度的 45%，限定在 200–360 之间，避免小屏超出
  double _bodyMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return (screenHeight * 0.45).clamp(200.0, 360.0);
  }

  Future<void> _onUpdatePressed() async {
    final target = _targetUrl();
    if (target == null) return;
    await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    if (!widget.info.isForceUpdate && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// iOS 跳转 App Store（未上架时 appStoreUrl 为空，返回 null）；Android 跳转接口返回的 fileurl。
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
    final canUpdate = _targetUrl() != null;

    return PopScope(
      canPop: !isForce,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(info),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200, maxHeight: _bodyMaxHeight(context)),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Text(
                          info.releaseNotes.isEmpty ? '发现新版本，建议立即更新' : info.releaseNotes,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.onSurface),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!isForce)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => setState(() => _dontRemindToday = !_dontRemindToday),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(value: _dontRemindToday, onChanged: (_) {}, visualDensity: VisualDensity.compact),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('今日不再提醒', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ),
              const Divider(height: 1, color: AppColors.divider),
              SizedBox(
                height: 54,
                child: Row(
                  children: [
                    if (!isForce) ...[
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, shape: const RoundedRectangleBorder()),
                          onPressed: _onLaterPressed,
                          child: const Text('稍后再说', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppColors.divider),
                    ],
                    Expanded(
                      child: Opacity(
                        opacity: canUpdate ? 1 : 0.5,
                        child: InkWell(
                          onTap: canUpdate ? _onUpdatePressed : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(gradient: _gradient),
                            child: const Text(
                              '立即更新',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶部蓝色渐变区：标题 + 版本号 + 装饰图标（后续可替换为设计稿插画）
  Widget _buildHeader(AppUpdateInfo info) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(gradient: _gradient),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Positioned(right: 28, top: 12, child: Icon(Icons.rocket_launch_rounded, size: 44, color: Colors.white.withValues(alpha: 0.9))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '发现新版本',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  info.displayVersion.isEmpty ? '' : 'V${info.displayVersion}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
