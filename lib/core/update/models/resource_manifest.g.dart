// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceItem _$ResourceItemFromJson(Map<String, dynamic> json) =>
    ResourceItem(localPath: json['localPath'] as String, remoteUrl: json['remoteUrl'] as String, md5: json['md5'] as String);

Map<String, dynamic> _$ResourceItemToJson(ResourceItem instance) => <String, dynamic>{
  'localPath': instance.localPath,
  'remoteUrl': instance.remoteUrl,
  'md5': instance.md5,
};

ResourceManifest _$ResourceManifestFromJson(Map<String, dynamic> json) => ResourceManifest(
  manifestVersion: json['manifestVersion'] as String,
  resources: (json['resources'] as List<dynamic>).map((e) => ResourceItem.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$ResourceManifestToJson(ResourceManifest instance) => <String, dynamic>{
  'manifestVersion': instance.manifestVersion,
  'resources': instance.resources.map((e) => e.toJson()).toList(),
};
