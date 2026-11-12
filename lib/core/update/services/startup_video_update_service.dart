import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../app/config/app_config.dart';
import '../../storage/local_storage.dart';

/// 负责自有服务器首页启动视频（open.mp4）的热更新管理服务
class StartupVideoUpdateService {
  StartupVideoUpdateService({Dio? dio, LocalStorage? storage}) : _dio = dio ?? Dio(), _storage = storage ?? LocalStorage();

  final Dio _dio;
  final LocalStorage _storage;

  static const String _localVideoMd5Key = 'startup_video_local_md5';
  static const String _videoFileName = 'open.mp4';

  /// 获取本地视频保存的目录
  Future<Directory> _getVideoDirectory() async {
    try {
      final baseDir = await getApplicationCacheDirectory();
      final dir = Directory('${baseDir.path}/startup_video');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory('${tempDir.path}/startup_video');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
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

  /// 检查自有服务器是否有视频更新，并在后台静默下载
  Future<bool> checkAndDownloadUpdate() async {
    try {
      final dir = await _getVideoDirectory();
      final targetFile = File('${dir.path}/$_videoFileName');
      final tmpFile = File('${dir.path}/$_videoFileName.tmp');

      // 1. 先尝试获取 Manifest 清单/配置
      final remoteInfo = await _fetchRemoteVideoInfo();
      if (remoteInfo == null) {
        return false;
      }

      final String targetMd5 = remoteInfo.md5;
      final String videoUrl = remoteInfo.videoUrl;

      // 2. 校验本地已有视频的 MD5
      final localMd5 = await _storage.getString(_localVideoMd5Key) ?? '';
      if (await targetFile.exists() && localMd5.isNotEmpty && localMd5 == targetMd5) {
        // 本地已有完整且匹配的视频，无需重新下载
        return false;
      }

      // 3. 下载到临时文件
      if (await tmpFile.exists()) {
        await tmpFile.delete();
      }

      AppLogger.info('开始从自有服务器下载最新启动视频: $videoUrl', module: 'startup_video_update');
      await _dio.download(
        videoUrl,
        tmpFile.path,
        options: Options(receiveTimeout: const Duration(seconds: 60), connectTimeout: const Duration(seconds: 15)),
      );

      if (!await tmpFile.exists() || await tmpFile.length() <= 0) {
        AppLogger.warning('下载视频文件为空', module: 'startup_video_update');
        return false;
      }

      // 4. 计算下载文件的 MD5 指纹
      final downloadedBytes = await tmpFile.readAsBytes();
      final downloadedMd5 = md5.convert(downloadedBytes).toString();

      if (targetMd5.isNotEmpty && downloadedMd5 != targetMd5) {
        AppLogger.warning('MD5 校验失败: downloaded=$downloadedMd5, target=$targetMd5', module: 'startup_video_update');
        if (await tmpFile.exists()) {
          await tmpFile.delete();
        }
        return false;
      }

      // 5. 校验通过，原子替换覆盖旧文件并更新记录
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tmpFile.rename(targetFile.path);

      final finalMd5 = targetMd5.isNotEmpty ? targetMd5 : downloadedMd5;
      await _storage.putString(_localVideoMd5Key, finalMd5);

      AppLogger.info('启动视频热更新成功! MD5: $finalMd5', module: 'startup_video_update');
      return true;
    } catch (e) {
      AppLogger.error('检查或下载热更新视频异常', module: 'startup_video_update', error: e);
      return false;
    }
  }

  /// 从自有服务器拉取视频配置（兼容 Manifest 格式与单视频 Config 格式）
  Future<({String videoUrl, String md5})?> _fetchRemoteVideoInfo() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/resources/video/config.json',
      options: Options(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)),
    );
    if (response.data == null) return null;
    final data = response.data!;
    final rawUrl = data['videoUrl'] as String? ?? 'resources/video/open.mp4';
    final remoteMd5 = data['md5'] as String? ?? '';
    final fullUrl = rawUrl.startsWith('http') ? rawUrl : '${AppConfig.baseUrl}/${rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl}';
    return (videoUrl: fullUrl, md5: remoteMd5);
  }
}
