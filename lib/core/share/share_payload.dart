/// 可被多个业务页面复用的分享内容。
///
/// [url] 仅允许传入真实可访问的网页地址；应用内路由不是网页分享地址。
class SharePayload {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;

  const SharePayload({required this.title, this.description, this.url, this.imageUrl});

  /// 构造商城 H5 openapp 包装链接，appUrl 必须是 App 已注册的真实 Schema URI。
  static Uri buildOpenAppUrl({required String appUrl, String baseUrl = 'https://m.mall.qkj.com.cn/mob/common/openapp'}) {
    final uri = Uri.tryParse(appUrl);
    if (uri == null || uri.scheme.isEmpty) {
      throw ArgumentError.value(appUrl, 'appUrl', '必须是带 Scheme 的 App Deep Link URI');
    }
    return Uri.parse(baseUrl).replace(queryParameters: {'appurl': uri.toString()});
  }

  String? get plainDescription {
    final value = description?.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get hasShareableUrl {
    final value = url?.trim();
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }

  String get plainText {
    final parts = <String>[title.trim(), ?plainDescription, if (hasShareableUrl) url!.trim()].where((part) => part.isNotEmpty);
    return parts.join('\n');
  }
}
