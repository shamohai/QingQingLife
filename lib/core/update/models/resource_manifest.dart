import 'package:json_annotation/json_annotation.dart';

part 'resource_manifest.g.dart';

/// 单个资源描述信息
@JsonSerializable()
class ResourceItem {
  final String localPath;
  final String remoteUrl;
  final String md5;

  const ResourceItem({required this.localPath, required this.remoteUrl, required this.md5});

  factory ResourceItem.fromJson(Map<String, dynamic> json) => _$ResourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceItemToJson(this);
}

/// 资源版本清单
@JsonSerializable()
class ResourceManifest {
  final String manifestVersion;
  final List<ResourceItem> resources;

  const ResourceManifest({required this.manifestVersion, required this.resources});

  factory ResourceManifest.fromJson(Map<String, dynamic> json) => _$ResourceManifestFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceManifestToJson(this);
}
