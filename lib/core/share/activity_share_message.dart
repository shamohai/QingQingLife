import 'dart:convert';

import 'share_payload.dart';

/// H5 activity WebView share payload from either AppShare or drinkShare bridge.
class ActivityShareMessage {
  final String? title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? returnUrl;
  final String? drinkShareUrl;
  final bool useDrinkMapOpenAppUrl;

  const ActivityShareMessage({this.title, this.description, this.url, this.imageUrl, this.returnUrl, this.drinkShareUrl, this.useDrinkMapOpenAppUrl = false});

  /// Parses either the app's existing JSON contract or the documented drinkShare contract.
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
      if (shareUrl != null) {
        final returnUrl = readString('returnUrl');
        final shareTitle = readString('shareTitle');
        final thumbnail = readString('thumbnail');
        if (returnUrl == null || shareTitle == null || thumbnail == null) return null;
        return ActivityShareMessage(
          title: shareTitle,
          url: shareUrl,
          imageUrl: thumbnail,
          returnUrl: returnUrl,
          drinkShareUrl: shareUrl,
          useDrinkMapOpenAppUrl: true,
        );
      }
      return ActivityShareMessage(title: readString('title'), description: readString('description'), url: readString('url'), imageUrl: readString('imageUrl'));
    } on FormatException {
      return null;
    }
  }

  SharePayload toSharePayload({required String fallbackTitle, required String? fallbackUrl, void Function(Uri returnUrl)? onDrinkShareSucceeded}) {
    final candidateUrl = _validWebUrl(url) ? url : fallbackUrl;
    final candidateImageUrl = _validWebUrl(imageUrl) ? imageUrl : null;
    final resolvedUrl = _validWebUrl(candidateUrl) ? candidateUrl : null;
    if (useDrinkMapOpenAppUrl && returnUrl != null && drinkShareUrl != null && _validWebUrl(drinkShareUrl) && _validWebUrl(returnUrl)) {
      final appUrl = drinkShareUrl!;
      final appLink = 'qqsh://app/activity/drinkmap/index?from=share&url=${Uri.encodeComponent(appUrl)}';
      final wrappedUrl = _buildOpenAppUrl(appLink);
      final callback = Uri.tryParse(returnUrl!);
      if (callback == null || (callback.scheme != 'http' && callback.scheme != 'https') || callback.host.isEmpty) {
        return SharePayload(
          title: title == null || title!.isEmpty ? fallbackTitle : title!,
          description: description,
          url: wrappedUrl,
          imageUrl: candidateImageUrl,
        );
      }
      return SharePayload(
        title: title == null || title!.isEmpty ? fallbackTitle : title!,
        description: description,
        url: wrappedUrl,
        imageUrl: candidateImageUrl,
        returnUrl: returnUrl,
        onDrinkShareSucceeded: onDrinkShareSucceeded,
      );
    }
    return SharePayload(
      title: title == null || title!.isEmpty ? fallbackTitle : title!,
      description: description,
      url: resolvedUrl,
      imageUrl: candidateImageUrl,
      returnUrl: returnUrl,
      wrapWithDrinkMapOpenApp: useDrinkMapOpenAppUrl,
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
