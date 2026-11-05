import '../../app/config/app_config.dart';
import '../../app/router/route_names.dart';

/// App 内页面链接的生成与解析。
///
/// 对外分享统一使用商城 H5 的 openapp 包装地址，包装参数 [appUrl] 指向
/// `qingqinglife://` Schema。这样微信、浏览器等外部环境可以正常打开链接，
/// 再由 H5 拉起 App。
abstract final class AppLink {
  /// 将应用内路由（可包含 query 参数）转换为 Schema 链接。
  ///
  /// 例如 `/points/service/12?from=share` 会生成
  /// `qingqinglife:///points/service/12?from=share`。
  static String buildSchemaUrl({required String location}) {
    final route = _normalizeLocation(location);
    return '${AppConfig.appScheme}://${route.toString()}';
  }

  /// 将应用内路由转换为可对外分享的 H5 openapp 链接。
  static String buildOpenAppUrl({required String location}) {
    final schemaUrl = buildSchemaUrl(location: location);
    return Uri.parse(AppConfig.openAppUrl).replace(queryParameters: {'appurl': schemaUrl}).toString();
  }

  /// 构造统一的 App 内链接分发入口地址。
  ///
  /// [route] 是最终要打开的应用内路由，其余参数会交给分发页，
  /// 由分发页校验后再跳转。
  static String buildDispatchLocation({required String route, Map<String, String?> parameters = const {}}) {
    final target = validateLocation(route);
    if (target == null || _isDispatchPath(Uri.parse(target).path)) {
      throw ArgumentError.value(route, 'route', '不是允许打开的应用内路由');
    }

    final query = <String, String>{'route': target};
    parameters.forEach((key, value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) query[key] = trimmed;
    });
    return Uri(path: RouteNames.appLinkDispatch, queryParameters: query).toString();
  }

  /// 从分发页 query 中解析最终目标路由。
  static String? resolveDispatchTarget(Map<String, String> queryParameters) {
    final route = queryParameters['route']?.trim();
    if (route == null || route.isEmpty) return null;

    final validatedRoute = validateLocation(route);
    if (validatedRoute == null) return null;
    final targetUri = Uri.parse(validatedRoute);
    if (_isDispatchPath(targetUri.path)) return null;

    final parameters = <String, String>{};
    queryParameters.forEach((key, value) {
      if (key != 'route' && value.trim().isNotEmpty) parameters[key] = value;
    });
    final merged = <String, String>{...targetUri.queryParameters, ...parameters};
    final location = Uri(path: targetUri.path, queryParameters: merged.isEmpty ? null : merged).toString();
    return validateLocation(location);
  }

  static bool _isDispatchPath(String path) => path == RouteNames.appLinkDispatch;

  /// 校验应用内路由，返回规范化后的 location；非法路由返回 null。
  static String? validateLocation(String location) {
    final uri = Uri.tryParse(location.trim());
    if (uri == null || uri.hasScheme || uri.hasAuthority || !uri.path.startsWith('/') || uri.path.startsWith('//')) {
      return null;
    }
    final path = _normalizePath(uri.path);
    if (path == null || !_isAllowedPath(path)) return null;
    if (RouteNames.deepLinkBlockedPaths.contains(path)) return null;
    if (path == RouteNames.login || path == RouteNames.phoneBind) return null;
    return Uri(path: path, query: uri.hasQuery ? uri.query : null).toString();
  }

  /// 从外部接收到的链接中解析应用内路由；无法识别或不允许的链接返回 null。
  ///
  /// 支持以下格式：
  /// - `qingqinglife:///points/service/12?from=share`
  /// - `qingqinglife://points/service/12?from=share`
  /// - `qingqinglife://app/points/service/12?from=share`
  /// - H5 openapp 链接中的 `appurl` 参数
  static String? toAppLocation(Uri link, {bool allowOpenAppWrapper = true}) {
    final unwrapped = allowOpenAppWrapper ? _unwrapOpenAppLink(link) : link;
    if (unwrapped == null || unwrapped.scheme.toLowerCase() != AppConfig.appScheme) {
      return null;
    }

    final resolved = _resolveLink(unwrapped);
    if (resolved == null) return null;
    return validateLocation(resolved.toString());
  }

  static Uri _normalizeLocation(String location) {
    final value = location.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.hasAuthority || !uri.path.startsWith('/') || uri.path.startsWith('//')) {
      throw ArgumentError.value(location, 'location', '必须是应用内绝对路由，例如 /points/service/12');
    }
    return uri;
  }

  static Uri? _unwrapOpenAppLink(Uri link) {
    if (link.scheme.toLowerCase() == AppConfig.appScheme) return link;
    final base = Uri.tryParse(AppConfig.openAppUrl);
    if (base == null || link.scheme.toLowerCase() != base.scheme || link.host.toLowerCase() != base.host.toLowerCase()) {
      return null;
    }
    if (!link.path.startsWith(base.path)) return null;
    final appUrl = link.queryParameters['appurl'];
    if (appUrl == null || appUrl.trim().isEmpty) return null;
    final nested = Uri.tryParse(appUrl);
    if (nested == null || nested.scheme.toLowerCase() != AppConfig.appScheme) return null;
    return nested;
  }

  static Uri? _resolveLink(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'open') {
      final nested = uri.queryParameters['appurl'];
      if (nested != null && nested.trim().isNotEmpty) {
        final nestedUri = Uri.tryParse(nested);
        if (nestedUri != null && nestedUri.scheme.toLowerCase() == AppConfig.appScheme) {
          return _resolveLink(nestedUri);
        }
      }
    }

    final rawPath = host.isEmpty || host == 'app' ? uri.path : '/$host${uri.path}';
    final path = _normalizePath(rawPath);
    if (path == null) return null;
    return Uri(path: path, query: uri.hasQuery ? uri.query : null);
  }

  static String? _normalizePath(String rawPath) {
    final segments = Uri(path: rawPath).pathSegments;
    if (segments.isEmpty) return null;

    final normalized = <String>[];
    for (final segment in segments) {
      if (segment.isEmpty || segment == '.' || segment == '..' || !RegExp(r'^[A-Za-z0-9._~-]+$').hasMatch(segment)) {
        return null;
      }
      normalized.add(segment);
    }
    return '/${normalized.join('/')}';
  }

  static bool _isAllowedPath(String path) {
    final segments = Uri(path: path).pathSegments;
    return RouteNames.deepLinkRoutes.any((template) {
      final templateSegments = Uri(path: template).pathSegments;
      if (templateSegments.length != segments.length) return false;
      for (var i = 0; i < templateSegments.length; i++) {
        if (templateSegments[i].startsWith(':')) continue;
        if (templateSegments[i] != segments[i]) return false;
      }
      return true;
    });
  }
}
