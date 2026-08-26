import 'package:json_annotation/json_annotation.dart';

part 'resource_manifest.g.dart';

/// 资源版本清单
@JsonSerializable()
class ResourceManifest {
  final String manifestVersion;
  final Map<String, String> resources;

  const ResourceManifest({
    required this.manifestVersion,
    required this.resources,
  });

  factory ResourceManifest.fromJson(Map<String, dynamic> json) =>
      _$ResourceManifestFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceManifestToJson(this);
}
