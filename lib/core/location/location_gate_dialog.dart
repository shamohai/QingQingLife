import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 定位门禁弹窗的展示内容。
class LocationGateDialogContent {
  final String title;
  final String message;
  final String confirmText;
  final IconData icon;

  const LocationGateDialogContent({required this.title, required this.message, required this.confirmText, required this.icon});
}

/// 定位门禁专用弹窗：风格与应用更新弹窗统一（渐变头部、圆角、底部双按钮）。
/// 返回 true 表示点击确认，false 或 null 表示取消。
Future<bool?> showLocationGateDialog(BuildContext context, LocationGateDialogContent content) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LocationGateDialog(content: content),
  );
}

class _LocationGateDialog extends StatelessWidget {
  const _LocationGateDialog({required this.content});

  final LocationGateDialogContent content;

  static const _gradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3152AF), Color(0xFF213775)]);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Text(
                content.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.onSurface),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(
              height: 54,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, shape: const RoundedRectangleBorder()),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary, shape: const RoundedRectangleBorder()),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(content.confirmText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(gradient: _gradient),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(content.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
