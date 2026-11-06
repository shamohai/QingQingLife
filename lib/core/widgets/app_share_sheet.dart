import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../share/share_payload.dart';
import '../share/share_provider.dart';
import '../share/share_service.dart';
import 'app_bottom_sheet.dart';

/// 全应用统一的分享面板；不具备真实网页 URL 时仅展示系统分享。
abstract final class AppShareSheet {
  static Future<void> show({required BuildContext context, required SharePayload payload}) {
    return AppBottomSheet.show<void>(
      context: context,
      backgroundColor: Colors.white,
      child: _ShareSheetContent(rootContext: context, payload: payload),
    );
  }

  /// 分享当前 App 页面。
  ///
  /// [location] 是应用内绝对路由，可携带 query 参数。分享出去的链接会通过
  /// openapp 包装携带 Schema，用户点击后由深链接收器打开对应页面。
  static Future<void> showAppPage({required BuildContext context, required String title, required String location, String? description, String? imageUrl}) {
    return show(
      context: context,
      payload: SharePayload.appPage(title: title, location: location, description: description, imageUrl: imageUrl),
    );
  }
}

class _ShareSheetContent extends ConsumerWidget {
  final BuildContext rootContext;
  final SharePayload payload;

  const _ShareSheetContent({required this.rootContext, required this.payload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = <(ShareChannel, String, IconData?, String?)>[
      if (payload.hasShareableUrl) ...[
        (ShareChannel.weChat, '微信好友', null, 'assets/icon/icon_wechat.png'),
        (ShareChannel.weChatTimeline, '朋友圈', null, 'assets/icon/icon_group.png'),
      ],
      if (payload.hasShareableUrl) (ShareChannel.copyLink, '复制链接', null, 'assets/icon/icon_copy.png'),
      (ShareChannel.system, '更多', Icons.more_horiz, null),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const Expanded(
                    child: Text('分享到', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(tooltip: '关闭', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (channels.length <= 4)
              Row(
                mainAxisAlignment: channels.length < 4 ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                children: [
                  for (final (channel, label, icon, asset) in channels)
                    channels.length < 4
                        ? SizedBox(
                            width: 72,
                            child: _ShareChannelButton(label: label, icon: icon, asset: asset, onTap: () => _share(context, ref, channel)),
                          )
                        : Expanded(
                            child: _ShareChannelButton(label: label, icon: icon, asset: asset, onTap: () => _share(context, ref, channel)),
                          ),
                ],
              )
            else
              Wrap(
                alignment: WrapAlignment.start,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final (channel, label, icon, asset) in channels)
                    SizedBox(
                      width: 68,
                      child: _ShareChannelButton(label: label, icon: icon, asset: asset, onTap: () => _share(context, ref, channel)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext sheetContext, WidgetRef ref, ShareChannel channel) async {
    final messenger = ScaffoldMessenger.maybeOf(rootContext);
    final shareService = ref.read(shareServiceProvider);
    Navigator.of(sheetContext).pop();
    final result = await shareService.share(payload, channel);
    if (!rootContext.mounted || messenger == null) return;
    final message = switch (result.status) {
      ShareActionStatus.success => channel == ShareChannel.copyLink ? '链接已复制' : null,
      ShareActionStatus.dismissed => null,
      ShareActionStatus.unavailable => result.message ?? '当前设备暂不支持此分享方式',
      ShareActionStatus.failed => result.message ?? '分享失败，请稍后重试',
    };
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
    }
  }
}

class _ShareChannelButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;

  const _ShareChannelButton({required this.label, this.icon, this.asset, required this.onTap}) : assert(icon != null || asset != null);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryContainer,
                child: asset != null ? Image.asset(asset!, width: 50, height: 50, fit: BoxFit.contain) : Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
