import '../deeplink/app_link.dart';

/// 可被多个业务页面复用的分享内容。
///
/// [url] 仅允许传入真实可访问的网页地址。分享 App 页面时使用
/// [SharePayload.appPage]，由 [AppLink] 生成带 Schema 参数的 openapp 链接。
class SharePayload {
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? returnUrl;
  final bool wrapWithDrinkMapOpenApp;
  final void Function(Uri returnUrl)? onDrinkShareSucceeded;

  const SharePayload({
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.returnUrl,
    this.wrapWithDrinkMapOpenApp = false,
    this.onDrinkShareSucceeded,
  });

  /// Constructs the activity app-aware sharing URL and successful-share callback URL.
  Uri get shareUrlForSharing {
    final shareUri = Uri.parse(url!);
    final cleanedUri = _cleanShareUri(shareUri);
    if (!wrapWithDrinkMapOpenApp) return cleanedUri;
    final appLink = 'qqsh://app/activity/drinkmap/index?from=share&url=${Uri.encodeComponent(cleanedUri.toString())}';
    return Uri(scheme: 'https', host: 'm.mall.qkj.com.cn', path: '/mob/common/openapp', queryParameters: {'appurl': appLink});
  }

  static Uri _cleanShareUri(Uri uri) {
    const keysToRemove = {'lnglat', 'province', 'accesstoken', 't', 'area'};

    final cleanedQuery = Map<String, String>.from(uri.queryParameters);
    cleanedQuery.removeWhere((key, _) => keysToRemove.contains(key.toLowerCase()));

    String? cleanedFragment = uri.fragment;
    if (uri.fragment.isNotEmpty) {
      final fragmentParts = uri.fragment.split('?');
      final fragmentPath = fragmentParts.first;
      if (fragmentParts.length > 1) {
        final fragmentQueryStr = fragmentParts.sublist(1).join('?');
        final fragmentParams = Uri.splitQueryString(fragmentQueryStr);
        fragmentParams.removeWhere((key, _) => keysToRemove.contains(key.toLowerCase()));
        if (fragmentParams.isNotEmpty) {
          final encodedFragmentQuery = fragmentParams.entries
              .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
              .join('&');
          cleanedFragment = '$fragmentPath?$encodedFragmentQuery';
        } else {
          cleanedFragment = fragmentPath;
        }
      }
    }

    if (!uri.hasQuery && cleanedQuery.isEmpty) {
      return uri.replace(fragment: cleanedFragment.isEmpty ? null : cleanedFragment);
    }

    final replaced = uri.replace(
      query: cleanedQuery.isEmpty ? '' : null,
      queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery,
      fragment: cleanedFragment.isEmpty ? null : cleanedFragment,
    );

    var resultStr = replaced.toString();
    if (uri.hasQuery && cleanedQuery.isEmpty) {
      if (resultStr.contains('?#')) {
        resultStr = resultStr.replaceFirst('?#', '#');
      } else if (resultStr.endsWith('?')) {
        resultStr = resultStr.substring(0, resultStr.length - 1);
      }
    }
    return Uri.parse(resultStr);
  }

  Uri? get shareSuccessReturnUrl {
    final value = returnUrl?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) return null;

    if (uri.fragment.isNotEmpty || value.contains('#')) {
      final fragmentParts = uri.fragment.split('?');
      final fragmentPath = fragmentParts.first;
      final fragmentQuery = fragmentParts.length > 1 ? fragmentParts.sublist(1).join('?') : '';
      final fragmentParameters = <String, String>{if (fragmentQuery.isNotEmpty) ...Uri.splitQueryString(fragmentQuery), 'share': '1'};
      final encodedFragmentParameters = fragmentParameters.entries
          .map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
          .join('&');
      final nextFragment = fragmentQuery.isEmpty && fragmentPath.isEmpty ? '?$encodedFragmentParameters' : '$fragmentPath?$encodedFragmentParameters';
      final withoutFragment = value.split('#').first;
      return Uri.parse('$withoutFragment#$nextFragment');
    }

    return uri.replace(queryParameters: {...uri.queryParameters, 'share': '1'});
  }

  /// 分享一个 App 内页面，点击分享链接后回到 App 并打开 [location]。
  ///
  /// [location] 必须是应用内绝对路由，可携带 query 参数，例如
  /// `/points/service/12?from=share`。
  factory SharePayload.appPage({required String title, required String location, String? description, String? imageUrl}) {
    return SharePayload(
      title: title,
      description: description,
      imageUrl: imageUrl,
      url: AppLink.buildOpenAppUrl(location: location),
    );
  }

  /// 构造商城 H5 openapp 包装链接，appUrl 必须是 App 已注册的真实 Schema URI。
  ///
  /// 业务页面优先使用 [SharePayload.appPage]，避免手工拼接 Schema。
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
    final parts = <String>[title.trim(), ?plainDescription, if (hasShareableUrl) shareUrlForSharing.toString()].where((part) => part.isNotEmpty);
    return parts.join('\n');
  }
}
