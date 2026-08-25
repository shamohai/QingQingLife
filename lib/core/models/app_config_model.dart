import 'package:json_annotation/json_annotation.dart';

part 'app_config_model.g.dart';

/// App 配置 Model（json_serializable 示例模板）
///
/// 后续业务 Model 参照此结构编写。
@JsonSerializable()
class AppConfigModel {
  final String appName;
  final String version;
  final bool maintenanceMode;

  const AppConfigModel({
    required this.appName,
    required this.version,
    required this.maintenanceMode,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AppConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigModelToJson(this);
}