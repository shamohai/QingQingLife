import 'dart:convert';

import 'share_payload.dart';

/// H5 activity WebView share payload from the AppShare bridge.
class ActivityShareMessage {
  final String? title;
  final String? description;
  final String? url;
  final String? imageUrl;

  const ActivityShareMessage({this.title, this.description, this.url, this.imageUrl});

  /// Parses the legacy AppShare JSON contract.
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

      return ActivityShareMessage(title: readString('title'), description: readString('description'), url: readString('url'), imageUrl: readString('imageUrl'));
    } on FormatException {
      return null;
    }
  }

  SharePayload toSharePayload({required String fallbackTitle, required String? fallbackUrl}) {
    final candidateUrl = _validWebUrl(url) ? url : fallbackUrl;
    final candidateImageUrl = _validWebUrl(imageUrl) ? imageUrl : null;
    final resolvedUrl = _validWebUrl(candidateUrl) ? candidateUrl : null;

    return SharePayload(
      title: title == null || title!.isEmpty ? fallbackTitle : title!,
      description: description,
      url: resolvedUrl,
      imageUrl: candidateImageUrl,
    );
  }

  static bool _validWebUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }
}
