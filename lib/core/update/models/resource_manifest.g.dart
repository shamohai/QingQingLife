// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceManifest _$ResourceManifestFromJson(Map<String, dynamic> json) =>
    ResourceManifest(
      manifestVersion: json['manifestVersion'] as String,
      resources: Map<String, String>.from(json['resources'] as Map),
    );

Map<String, dynamic> _$ResourceManifestToJson(ResourceManifest instance) =>
    <String, dynamic>{
      'manifestVersion': instance.manifestVersion,
      'resources': instance.resources,
    };
