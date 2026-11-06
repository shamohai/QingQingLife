import 'dart:typed_data';

import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/services.dart' hide Uint8List;
import 'package:share_plus/share_plus.dart';

import 'share_payload.dart';
import 'wechat_thumbnail_helper.dart';

enum ShareChannel { weChat, weChatTimeline, system, copyLink }

enum ShareActionStatus { success, dismissed, unavailable, failed }

class ShareActionResult {
  final ShareActionStatus status;
  final String? message;

  const ShareActionResult(this.status, {this.message});
}

/// 分享渠道的统一入口；平台 SDK 细节不泄漏到业务页面。
abstract class ShareService {
  Future<ShareActionResult> share(SharePayload payload, ShareChannel channel);
}

class FluwxShareService implements ShareService {
  final fluwx.Fluwx wechat;
  final SharePlus _systemShare;
  final WeChatThumbnailHelper _thumbnailHelper;

  FluwxShareService({required this.wechat, SharePlus? systemShare, WeChatThumbnailHelper? thumbnailHelper})
    : _systemShare = systemShare ?? SharePlus.instance,
      _thumbnailHelper = thumbnailHelper ?? WeChatThumbnailHelper();

  @override
  Future<ShareActionResult> share(SharePayload payload, ShareChannel channel) async {
    try {
      switch (channel) {
        case ShareChannel.weChat:
        case ShareChannel.weChatTimeline:
          final result = await _shareToWeChat(payload, channel);
          return _completeDrinkShare(payload, result);
        case ShareChannel.system:
          final result = await _systemShare.share(ShareParams(text: payload.plainText, subject: payload.title));
          return _completeDrinkShare(payload, switch (result.status) {
            ShareResultStatus.success => const ShareActionResult(ShareActionStatus.success),
            ShareResultStatus.dismissed => const ShareActionResult(ShareActionStatus.dismissed),
            ShareResultStatus.unavailable => const ShareActionResult(ShareActionStatus.unavailable),
          });
        case ShareChannel.copyLink:
          if (!payload.hasShareableUrl) {
            return const ShareActionResult(ShareActionStatus.unavailable, message: '暂无可复制的分享链接');
          }
          await Clipboard.setData(ClipboardData(text: payload.url!.trim()));
          return _completeDrinkShare(payload, const ShareActionResult(ShareActionStatus.success));
      }
    } catch (_) {
      return const ShareActionResult(ShareActionStatus.failed, message: '分享失败，请稍后重试');
    }
  }

  ShareActionResult _completeDrinkShare(SharePayload payload, ShareActionResult result) {
    final returnUrl = payload.shareSuccessReturnUrl;
    if (result.status == ShareActionStatus.success && returnUrl != null) {
      payload.onDrinkShareSucceeded?.call(returnUrl);
    }
    return result;
  }

  Future<ShareActionResult> _shareToWeChat(SharePayload payload, ShareChannel channel) async {
    if (!payload.hasShareableUrl) {
      return const ShareActionResult(ShareActionStatus.unavailable, message: '暂无可分享的网页链接');
    }
    if (!await wechat.isWeChatInstalled) {
      return const ShareActionResult(ShareActionStatus.unavailable, message: '请先安装微信');
    }

    Uint8List? thumbData;
    if (payload.imageUrl != null && payload.imageUrl!.trim().isNotEmpty) {
      thumbData = await _thumbnailHelper.fetchAndCompressThumbnail(payload.imageUrl);
    }

    final accepted = await wechat.share(
      fluwx.WeChatShareWebPageModel(
        payload.shareUrlForSharing.toString(),
        title: payload.title,
        description: payload.plainDescription,
        thumbData: thumbData,
        scene: channel == ShareChannel.weChat ? fluwx.WeChatScene.session : fluwx.WeChatScene.timeline,
      ),
    );
    return accepted ? const ShareActionResult(ShareActionStatus.success) : const ShareActionResult(ShareActionStatus.failed, message: '微信未能发起分享');
  }
}
