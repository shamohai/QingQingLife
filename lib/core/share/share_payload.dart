/// 可被多个业务页面复用的分享内容。
///
/// [url] 仅允许传入真实可访问的网页地址；应用内路由不是网页分享地址。
class SharePayload {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;

  const SharePayload({required this.title, this.description, this.url, this.imageUrl});

  bool get hasShareableUrl {
    final value = url?.trim();
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }

  String get plainText {
    final parts = <String>[
      title.trim(),
      if (description?.trim().isNotEmpty == true) description!.trim(),
      if (hasShareableUrl) url!.trim(),
    ].where((part) => part.isNotEmpty);
    return parts.join('\n');
  }
}
