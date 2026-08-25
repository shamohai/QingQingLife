// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfigModel _$AppConfigModelFromJson(Map<String, dynamic> json) =>
    AppConfigModel(
      appName: json['appName'] as String,
      version: json['version'] as String,
      maintenanceMode: json['maintenanceMode'] as bool,
    );

Map<String, dynamic> _$AppConfigModelToJson(AppConfigModel instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'version': instance.version,
      'maintenanceMode': instance.maintenanceMode,
    };
