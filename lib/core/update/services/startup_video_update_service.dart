import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../app/config/app_config.dart';
import '../../network/api_client.dart';
import 'check_update_client.dart';
import '../../storage/local_storage.dart';
import '../../storage/secure_storage.dart';
import '../models/resource_manifest.dart';

/// 单个资源的同步结果
enum _SyncOutcome { unchanged, updated, failed }

/// 自有服务器热更新管理服务
///
/// 流程：
/// 1. POST `/api/sys/app/checkupdate`，只传本地 `hotfixversion`，公共 meta 与 authtoken 由拦截器注入
/// 2. 响应 `hotfixversion.ishotfix == true` 时，GET 其 `fileurl` 得到资源清单 Manifest
/// 3. 逐项同步 Manifest.resources：
///    - `assets/video/open.mp4`：替换本地启动视频，MD5 变化后下次打开会重新播放
///    - 其他资源：下载到缓存目录，供业务按 localPath 读取
/// 4. 全部资源同步成功后才记录新的 hotfixversion，否则下次启动继续重试
class StartupVideoUpdateService {
  StartupVideoUpdateService({Dio? dio, ApiClient? apiClient, LocalStorage? storage})
    : _dio = dio ?? Dio(),
      _apiClient = apiClient ?? ApiClient(storage: SecureStorage()),
      _storage = storage ?? LocalStorage();

  /// 仅用于下载文件（视频、资源、Manifest），不经过加密签名拦截器
  final Dio _dio;
  final ApiClient _apiClient;
  final LocalStorage _storage;

  static const String _localVideoMd5Key = 'startup_video_local_md5';
  static const String _localHotfixVersionKey = 'hot_update_hotfix_version';
  static const String _localAppBuildNumberKey = 'local_app_build_number';

  static const String _resourceMd5KeyPrefix = 'resource_md5_';
  static const String _videoFileName = 'open.mp4';

  /// 新下载的待生效视频：只在下次启动时晋升为 open.mp4，本次启动不受影响
  static const String _pendingVideoFileName = 'open_pending.mp4';
  static const String _pendingVideoMd5Key = 'startup_video_pending_md5';
  static const String _videoLocalPath = 'assets/video/open.mp4';

  /// 热更新镜像根目录：与 apk 内资源路径一一对应，如 hot_assets/assets/video/open.mp4
  static const String _resourceDirName = 'hot_assets';
  static String? _hotRootPath;

  /// 热更新 CheckUpdate 接口路径（相对 baseUrl）

  /// 获取本地视频保存的目录
  Future<Directory> _getVideoDirectory() async {
    final root = await _getResourceDirectory();
    final dir = Directory('${root.path}/assets/video');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 获取通用资源保存的目录
  Future<Directory> _getResourceDirectory() async {
    final baseDir = await getApplicationCacheDirectory();
    final dir = Directory('${baseDir.path}/$_resourceDirName');
    _hotRootPath = dir.path;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 启动时检查原生 apk 构建号（在任何更新请求之前 await 完成）。
  ///
  /// - 首次安装：只记录当前构建号，不做任何清理。
  /// - 覆盖安装（构建号变化）：删除旧的热更新视频文件及其 MD5 记录，
  ///   避免旧热更新视频覆盖新 apk 内置的 open.mp4。
  ///   已记录的「已播放 MD5」（startup_video_played_md5）保留，不删除。
  Future<void> syncAppBuildOnLaunch() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = packageInfo.buildNumber;
      final savedBuild = await _storage.getString(_localAppBuildNumberKey) ?? '';

      if (savedBuild.isNotEmpty && savedBuild != currentBuild) {
        AppLogger.info('检测到 apk 构建号变化 ($savedBuild -> $currentBuild)，删除旧热更新视频', module: 'startup_video_update');
        final dir = await _getVideoDirectory();
        for (final name in [_videoFileName, '$_videoFileName.tmp', _pendingVideoFileName, '$_pendingVideoFileName.tmp']) {
          final f = File('${dir.path}/$name');
          if (await f.exists()) await f.delete();
        }
        await _storage.remove(_localVideoMd5Key);
        await _storage.remove(_pendingVideoMd5Key);
      }
      await _promotePendingVideo();
      await _storage.putString(_localAppBuildNumberKey, currentBuild);
    } catch (e) {
      AppLogger.warning('同步 apk 构建号异常', module: 'startup_video_update', data: {'error': e.toString()});
    }
  }

  /// 若有已下载完成的待生效视频，在启动时晋升为 open.mp4（先于播放判断执行）
  Future<void> _promotePendingVideo() async {
    final dir = await _getVideoDirectory();
    final pending = File('${dir.path}/$_pendingVideoFileName');
    final pendingMd5 = await _storage.getString(_pendingVideoMd5Key) ?? '';
    if (pendingMd5.isEmpty || !await pending.exists()) return;

    final active = File('${dir.path}/$_videoFileName');
    if (await active.exists()) await active.delete();
    await pending.rename(active.path);
    await _storage.putString(_localVideoMd5Key, pendingMd5);
    await _storage.remove(_pendingVideoMd5Key);
    AppLogger.info('待生效热更新视频已晋升为开机视频，MD5: $pendingMd5', module: 'startup_video_update');
  }

  /// 获取本地存储的合法热更新视频 File（若不存在或损坏则返回 null）
  Future<File?> getValidLocalVideoFile() async {
    try {
      final dir = await _getVideoDirectory();
      final file = File('${dir.path}/$_videoFileName');

      if (!await file.exists()) {
        return null;
      }

      final length = await file.length();
      if (length <= 0) {
        await file.delete();
        return null;
      }

      return file;
    } catch (e) {
      AppLogger.warning('校验本地视频失败', module: 'startup_video_update', error: e);
      return null;
    }
  }

  /// 检查自有服务器是否有热更新，并在后台静默下载
  ///
  /// 返回本次是否有内容实际更新（启动视频或通用资源）。
  Future<bool> checkAndDownloadUpdate() async {
    try {
      // 0. 原生包升级后清理旧热更新缓存，避免旧资源污染新原生包
      // 构建号已由 bootstrap 在启动时通过 syncAppBuildOnLaunch() 同步完成，此处不再重复

      // 1. 请求接口，获取热更新资源清单
      final hotfix = await _fetchHotfixManifest();
      if (hotfix == null) {
        return false;
      }

      // 2. 逐项同步资源；单项失败不影响其他资源
      var changed = false;
      var allSynced = true;
      for (final item in hotfix.manifest.resources) {
        final outcome = item.localPath == _videoLocalPath ? await _syncVideo(item) : await _syncResource(item);
        if (outcome == _SyncOutcome.updated) changed = true;
        if (outcome == _SyncOutcome.failed) allSynced = false;
      }

      // 3. 全部成功才记录 hotfixversion，失败则下次启动重新请求
      if (allSynced) {
        await _storage.putString(_localHotfixVersionKey, '${hotfix.hotfixVersion}');
        AppLogger.info('热更新同步完成，hotfixversion=${hotfix.hotfixVersion}', module: 'startup_video_update');
      } else {
        AppLogger.warning('部分热更新资源同步失败，hotfixversion 未更新，下次启动重试', module: 'startup_video_update');
      }
      return changed;
    } catch (e) {
      AppLogger.error('检查或下载热更新异常', module: 'startup_video_update', error: e);
      return false;
    }
  }

  /// 下载启动视频到待生效文件，不覆盖当前正在使用的 open.mp4
  Future<_SyncOutcome> _syncVideo(ResourceItem item) async {
    final dir = await _getVideoDirectory();
    final activeFile = File('${dir.path}/$_videoFileName');
    final pendingFile = File('${dir.path}/$_pendingVideoFileName');

    final activeMd5 = await _storage.getString(_localVideoMd5Key) ?? '';
    final pendingMd5 = await _storage.getString(_pendingVideoMd5Key) ?? '';
    final sameAsActive = activeMd5.toLowerCase() == item.md5.toLowerCase() && await activeFile.exists();
    final sameAsPending = pendingMd5.toLowerCase() == item.md5.toLowerCase() && await pendingFile.exists();
    if (sameAsActive || sameAsPending) return _SyncOutcome.unchanged;

    final ok = await _downloadVerified(item, pendingFile, receiveTimeout: const Duration(seconds: 60));
    if (!ok) return _SyncOutcome.failed;

    await _storage.putString(_pendingVideoMd5Key, item.md5);
    AppLogger.info('启动视频已下载，将于下次启动生效，MD5: ${item.md5}', module: 'startup_video_update');
    return _SyncOutcome.updated;
  }

  /// 同步通用资源（文件名由 localPath 转换而来，避免目录层级冲突）
  Future<_SyncOutcome> _syncResource(ResourceItem item) async {
    final dir = await _getResourceDirectory();
    final targetFile = File('${dir.path}/${item.localPath}');

    final storageKey = '$_resourceMd5KeyPrefix${item.localPath}';
    final localMd5 = await _storage.getString(storageKey) ?? '';
    if (await targetFile.exists() && localMd5.isNotEmpty && localMd5.toLowerCase() == item.md5.toLowerCase()) {
      return _SyncOutcome.unchanged;
    }

    final ok = await _downloadVerified(item, targetFile, receiveTimeout: const Duration(seconds: 30));
    if (!ok) return _SyncOutcome.failed;

    await _storage.putString(storageKey, item.md5);
    AppLogger.info('资源热更新成功: ${item.localPath}', module: 'startup_video_update');
    return _SyncOutcome.updated;
  }

  /// 下载到临时文件，校验 MD5 通过后原子替换目标文件
  Future<bool> _downloadVerified(ResourceItem item, File targetFile, {required Duration receiveTimeout}) async {
    final tmpFile = File('${targetFile.path}.tmp');
    try {
      if (item.md5.isEmpty) {
        AppLogger.warning('热更新资源缺少 md5，拒绝下载: ${item.localPath}', module: 'startup_video_update');
        return false;
      }

      if (await tmpFile.exists()) {
        await tmpFile.delete();
      }

      await targetFile.parent.create(recursive: true);
      await _dio.download(
        item.remoteUrl,
        tmpFile.path,
        options: Options(receiveTimeout: receiveTimeout, connectTimeout: const Duration(seconds: 15)),
      );

      if (!await tmpFile.exists() || await tmpFile.length() <= 0) {
        AppLogger.warning('下载文件为空: ${item.localPath}', module: 'startup_video_update');
        return false;
      }

      final downloadedMd5 = md5.convert(await tmpFile.readAsBytes()).toString();
      if (downloadedMd5 != item.md5.toLowerCase()) {
        AppLogger.warning('MD5 校验失败 (${item.localPath}): downloaded=$downloadedMd5, target=${item.md5}', module: 'startup_video_update');
        return false;
      }

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tmpFile.rename(targetFile.path);
      return true;
    } catch (e) {
      AppLogger.error('下载热更新文件异常 (${item.localPath})', module: 'startup_video_update', error: e);
      return false;
    } finally {
      if (await tmpFile.exists()) {
        await tmpFile.delete();
      }
    }
  }

  /// 请求 CheckUpdate 接口，若存在热更新则拉取并解析资源清单
  ///
  /// 请求体只包含本地热更新版本号 `hotfixversion`，其余 meta 由公共拦截器注入。
  /// 响应中 `hotfixversion.ishotfix == true` 时，`fileurl` 指向资源清单 Manifest。
  Future<({int hotfixVersion, ResourceManifest manifest})?> _fetchHotfixManifest() async {
    try {
      final data = await CheckUpdateClient.fetch(_apiClient, _storage);
      if (data == null) {
        return null;
      }
      final hotfix = data['hotfixversion'];
      if (hotfix is! Map || hotfix['ishotfix'] != true) {
        return null;
      }

      var fileUrl = hotfix['fileurl'] as String? ?? '';
      if (fileUrl.isEmpty) {
        AppLogger.warning('热更新信息缺少 fileurl', module: 'startup_video_update');
        return null;
      }
      if (!fileUrl.startsWith('http')) {
        fileUrl = '${AppConfig.baseUrl}${fileUrl.startsWith('/') ? '' : '/'}$fileUrl';
      }
      final hotfixVersion = (hotfix['buildnumber'] as num?)?.toInt() ?? 0;

      final manifestResponse = await _dio.get<dynamic>(
        fileUrl,
        options: Options(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 10)),
      );
      final raw = manifestResponse.data;
      final json = raw is String ? jsonDecode(raw) : raw;
      if (json is! Map<String, dynamic>) {
        AppLogger.warning('热更新 Manifest 格式错误', module: 'startup_video_update');
        return null;
      }

      final manifest = ResourceManifest.fromJson(json);
      AppLogger.info('获取热更新 Manifest 成功 (HotfixVersion/buildnumber: $hotfixVersion)', module: 'startup_video_update');
      return (hotfixVersion: hotfixVersion, manifest: manifest);
    } catch (e) {
      AppLogger.warning('请求热更新接口失败', module: 'startup_video_update', error: e);
      return null;
    }
  }
}

/// 资源读取：优先读取热更新镜像目录中的同名文件，没有则回退到 apk 内置资源
class HotAssetBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final root = StartupVideoUpdateService._hotRootPath;
    if (root != null) {
      final file = File('$root/$key');
      if (await file.exists()) {
        return ByteData.sublistView(await file.readAsBytes());
      }
    }
    return rootBundle.load(key);
  }
}
