// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => UpdateInfo(
  versionCode: (json['versionCode'] as num).toInt(),
  versionName: json['versionName'] as String,
  updateContent: json['updateContent'] as String,
  updateType:
      $enumDecodeNullable(_$UpdateTypeEnumMap, json['updateType']) ??
      UpdateType.none,
  downloadUrl: json['downloadUrl'] as String?,
  iosUrl: json['iosUrl'] as String?,
  minVersionCode: (json['minVersionCode'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateInfoToJson(UpdateInfo instance) =>
    <String, dynamic>{
      'versionCode': instance.versionCode,
      'versionName': instance.versionName,
      'updateContent': instance.updateContent,
      'updateType': _$UpdateTypeEnumMap[instance.updateType]!,
      'downloadUrl': instance.downloadUrl,
      'iosUrl': instance.iosUrl,
      'minVersionCode': instance.minVersionCode,
    };

const _$UpdateTypeEnumMap = {
  UpdateType.none: 'none',
  UpdateType.force: 'force',
  UpdateType.suggest: 'suggest',
  UpdateType.silent: 'silent',
};
