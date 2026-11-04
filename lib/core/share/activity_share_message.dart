import 'dart:convert';

import 'share_payload.dart';

/// H5 activity WebView share payload from the drinkShare bridge.
class ActivityShareMessage {
  final String title;
  final String url;
  final String imageUrl;
  final String returnUrl;
  final String drinkShareUrl;

  const ActivityShareMessage({required this.title, required this.url, required this.imageUrl, required this.returnUrl, required this.drinkShareUrl});

  /// Parses the documented drinkShare contract.
  static ActivityShareMessage? tryParse(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) return null;

      String? readString(String key) {
        final value = decoded[key];
        if (value == null) return null;
        if (value is! String) throw const FormatException('分享字段必须为字符串');
        return value.trim();
      }

      final shareUrl = readString('shareUrl');
      final returnUrl = readString('returnUrl');
      final shareTitle = readString('shareTitle');
      final thumbnail = readString('thumbnail');

      if (shareUrl == null || returnUrl == null || shareTitle == null || thumbnail == null) {
        return null;
      }
      if (!_validWebUrl(shareUrl) || !_validWebUrl(returnUrl) || !_validWebUrl(thumbnail)) {
        return null;
      }

      return ActivityShareMessage(title: shareTitle, url: shareUrl, imageUrl: thumbnail, returnUrl: returnUrl, drinkShareUrl: shareUrl);
    } on FormatException {
      return null;
    }
  }

  SharePayload toSharePayload({required String fallbackTitle, void Function(Uri returnUrl)? onDrinkShareSucceeded}) {
    final encodedShareUrl = Uri.encodeComponent(drinkShareUrl);
    final appLink = 'qqsh://app/activity/drinkmap/index?from=share&url=$encodedShareUrl';
    final wrappedUrl = _buildOpenAppUrl(appLink);

    return SharePayload(
      title: title.isEmpty ? fallbackTitle : title,
      url: wrappedUrl,
      imageUrl: imageUrl,
      returnUrl: returnUrl,
      onDrinkShareSucceeded: onDrinkShareSucceeded,
    );
  }

  static bool isValidWebUrl(String? value) => _validWebUrl(value);

  static String _buildOpenAppUrl(String appLink) {
    final encodedAppLink = Uri.encodeComponent(appLink);
    return 'https://m.mall.qkj.com.cn/mob/common/openapp?appurl=$encodedAppLink';
  }

  static bool _validWebUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }
}
