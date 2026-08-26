import 'package:json_annotation/json_annotation.dart';

part 'update_info.g.dart';

/// 更新类型枚举
enum UpdateType { none, force, suggest, silent }

/// 版本检查结果数据模型
@JsonSerializable()
class UpdateInfo {
  final int versionCode;
  final String versionName;
  final String updateContent;
  final UpdateType updateType;
  final String? downloadUrl;
  final String? iosUrl;
  final int? minVersionCode;

  const UpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.updateContent,
    this.updateType = UpdateType.none,
    this.downloadUrl,
    this.iosUrl,
    this.minVersionCode,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateInfoToJson(this);

  bool get shouldShowDialog =>
      updateType == UpdateType.force || updateType == UpdateType.suggest;

  bool get isForceUpdate => updateType == UpdateType.force;

  bool isLatest(int localVersionCode) => versionCode <= localVersionCode;
}
