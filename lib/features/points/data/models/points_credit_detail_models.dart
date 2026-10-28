/// /api/promotion/getcreditlist 返回的单条积分流水。
class PointsCreditRecord {
  final String id;
  final String title;
  final int payCredits;
  final String actionTimeText;

  const PointsCreditRecord({required this.id, required this.title, required this.payCredits, required this.actionTimeText});

  int get change => payCredits;

  factory PointsCreditRecord.fromJson(Map<String, dynamic> json) {
    return PointsCreditRecord(
      id: _text(json['id']),
      title: _text(json['title']),
      payCredits: _int(json['paycredits']),
      actionTimeText: _text(json['actiontime']),
    );
  }

  static String _text(dynamic value) => value?.toString() ?? '';

  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// 积分明细接口的扁平业务数据。
class PointsCreditListData {
  final int totalDecrease;
  final int totalCredit;
  final int totalIncrease;
  final int totalRecords;
  final List<PointsCreditRecord> credits;

  const PointsCreditListData({
    required this.totalDecrease,
    required this.totalCredit,
    required this.totalIncrease,
    required this.totalRecords,
    required this.credits,
  });

  factory PointsCreditListData.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] is List
        ? (json['credits'] as List).whereType<Map>().map((item) => PointsCreditRecord.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <PointsCreditRecord>[];
    return PointsCreditListData(
      totalDecrease: _int(json['totaldecrease']),
      totalCredit: _int(json['totalcredit']),
      totalIncrease: _int(json['totalincrease']),
      totalRecords: _int(json['totalrecords']),
      credits: credits,
    );
  }

  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
