import 'dart:math' as math;

/// Required values for constructing the Weimeng activity H5 virtual-path query.
class WeimengActivityLocation {
  final String accessToken;
  final String longitude;
  final String latitude;
  final String province;
  final String area;

  const WeimengActivityLocation({required this.accessToken, required this.longitude, required this.latitude, required this.province, required this.area});
}

/// Builds the Weimeng / DrinkMap H5 URL while keeping cache busting before `#` and
/// SSO/location parameters inside the SPA virtual path after `#`.
Uri buildWeimengActivityUri(Uri uri, WeimengActivityLocation location, {String? timestamp, math.Random? random}) {
  final tValue = timestamp ?? (DateTime.now().millisecondsSinceEpoch.toString());
  final fragmentParts = uri.fragment.split('?');
  final fragmentPath = fragmentParts.first;
  final fragmentQuery = fragmentParts.length > 1 ? fragmentParts.sublist(1).join('?') : '';
  final fragmentParameters = <String, String>{
    if (fragmentQuery.isNotEmpty) ...Uri.splitQueryString(fragmentQuery),
    'lnglat': '${location.longitude},${location.latitude}',
    'province': location.province,
    'area': location.area,
    'accesstoken': location.accessToken,
  };
  final encodedFragmentParameters = fragmentParameters.entries
      .map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
      .join('&');
  final nextFragment = fragmentQuery.isEmpty && fragmentPath.isEmpty ? '?$encodedFragmentParameters' : '$fragmentPath?$encodedFragmentParameters';
  final outerParameters = <String, String>{...uri.queryParameters, 't': tValue};
  final outerQuery = Uri(queryParameters: outerParameters).query;
  final withoutFragment = uri.toString().split('#').first;
  final separator = Uri.parse(withoutFragment).hasQuery ? '&' : '?';
  return Uri.parse('$withoutFragment$separator$outerQuery#$nextFragment');
}
