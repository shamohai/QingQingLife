/// 可用福利信息。
class AvailableWelfareInfo {
  final int welfareType;
  final int welfareId;
  final String welfareName;
  final int count;

  const AvailableWelfareInfo({this.welfareType = 0, this.welfareId = 0, this.welfareName = '', this.count = 0});

  factory AvailableWelfareInfo.fromJson(Map<String, dynamic> json) {
    return AvailableWelfareInfo(
      welfareType: _asInt(json['welfaretype']),
      welfareId: _asInt(json['welfareid']),
      welfareName: json['welfarename']?.toString() ?? '',
      count: _asInt(json['count']),
    );
  }
}

/// 可用福利列表响应。
class AvailableWelfareListResult {
  final List<AvailableWelfareInfo> welfareList;
  final int totalCount;
  final int keepCount;
  final String? dataTag;

  const AvailableWelfareListResult({required this.welfareList, required this.totalCount, required this.keepCount, this.dataTag});

  factory AvailableWelfareListResult.fromJson(Map<String, dynamic> json) {
    final rawList = json['welfarelist'];
    final welfareList = rawList is List
        ? rawList.whereType<Map>().map((item) => AvailableWelfareInfo.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <AvailableWelfareInfo>[];

    return AvailableWelfareListResult(
      welfareList: welfareList,
      totalCount: _asInt(json['totalcount']),
      keepCount: _asInt(json['keepcount']),
      dataTag: json['datatag']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
