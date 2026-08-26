import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resource_manifest.dart';
import '../../../app/config/app_config.dart';

/// 资源热更服务
class ResourceUpdateService {
  final Dio _dio;
  static const _manifestVersionKey = 'resource_manifest_version';
  static const _lastCheckTimestampKey = 'resource_last_check_ts';

  late final Directory _cacheDir;

  ResourceUpdateService(this._dio) {
    _initCacheDir();
  }

  Future<void> _initCacheDir() async {
    try {
      final baseDir = await getApplicationCacheDirectory();
      _cacheDir = Directory('${baseDir.path}/resource_cache');
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/qingqinglife_resource_cache');
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }
    }
  }

  /// 执行资源热更检查与下载，返回是否发生了实际下载
  Future<bool> checkAndApply() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCheck = prefs.getInt(_lastCheckTimestampKey) ?? 0;
    if (now - lastCheck < 5 * 60 * 1000) {
      return false;
    }

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/app/resource/manifest',
      );
      final json = response.data as Map<String, dynamic>? ?? {};
      final manifest = ResourceManifest.fromJson(json);

      final localVersion = prefs.getString(_manifestVersionKey) ?? '';
      if (manifest.manifestVersion == localVersion) {
        return false;
      }

      await _downloadChangedResources(manifest, prefs);
      await prefs.setString(_manifestVersionKey, manifest.manifestVersion);
      await prefs.setInt(_lastCheckTimestampKey, now);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _downloadChangedResources(
      ResourceManifest manifest, SharedPreferences prefs) async {
    final localVersion = prefs.getString(_manifestVersionKey) ?? '';
    for (final entry in manifest.resources.entries) {
      final path = entry.key;
      final md5 = entry.value;
      if (localVersion.isNotEmpty) {
        final localMd5 = await _getResourceId(path);
        if (localMd5 == md5) continue;
      }
      final url = '${AppConfig.resourceCdnBaseUrl}/$path';
      try {
        await _dio.download(
          url,
          '${_cacheDir.path}/$path',
          options: Options(receiveTimeout: const Duration(seconds: 30)),
        );
      } catch (e) {
        debugPrint('[ResourceUpdate] Failed to download $url: $e');
      }
    }
  }

  Future<String> _getResourceId(String path) async {
    final file = File('${_cacheDir.path}/$path');
    if (!await file.exists()) return '';
    final stat = await file.stat();
    return '${stat.size}_${stat.modified.millisecondsSinceEpoch}';
  }

  String? getLocalCachePath(String resourcePath) {
    final filePath = '${_cacheDir.path}/$resourcePath';
    if (File(filePath).existsSync()) return filePath;
    return null;
  }

  Future<void> clearCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_manifestVersionKey);
    await prefs.remove(_lastCheckTimestampKey);
  }
}
