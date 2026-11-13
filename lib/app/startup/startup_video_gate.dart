import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/logging/app_logger.dart';
import '../../core/storage/local_storage.dart';
import '../../core/update/services/startup_video_update_service_stub.dart' if (dart.library.io) '../../core/update/services/startup_video_update_service.dart';

/// Controls the one-time startup video shown after an install or app upgrade.
class StartupVideoGate extends StatefulWidget {
  const StartupVideoGate({required this.child, super.key});

  final Widget child;

  @override
  State<StartupVideoGate> createState() => _StartupVideoGateState();
}

class _StartupVideoGateState extends State<StartupVideoGate> {
  static const _lastPlayedVersionKey = 'startup_video_last_played_version';
  static const _videoAsset = 'assets/video/open.mp4';

  final _storage = LocalStorage();
  StartupVideoUpdateService? _updateService;
  VideoPlayerController? _controller;
  bool _showVideo = false;
  bool _isReady = false;
  bool _autoplayBlocked = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _updateService = StartupVideoUpdateService();
    }
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final lastPlayedVersion = await _storage.getString(_lastPlayedVersionKey);
      final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      if (!mounted || lastPlayedVersion == currentVersion) {
        _finishWithoutVideo();
        return;
      }

      // -----------------------------------------------------------------
      // 1. Web 平台：严格保持修改前的原生处理逻辑，直接加载内置 Asset 视频
      // -----------------------------------------------------------------
      if (kIsWeb) {
        final controller = VideoPlayerController.asset(_videoAsset);
        await controller.initialize();
        await controller.setLooping(false);
        controller.addListener(_onVideoChanged);

        if (!mounted) {
          await controller.dispose();
          return;
        }

        setState(() {
          _controller = controller;
          _showVideo = true;
          _isReady = true;
        });
        // Chrome blocks audible autoplay. Muting before play allows the
        // startup video to begin automatically. If autoplay is still
        // blocked, keep the video visible and let the user start it.
        await controller.setVolume(0);
        await _playController(controller);
        return;
      }

      // -----------------------------------------------------------------
      // 2. 原生 App 平台（Android/iOS/Desktop）：支持自有服务器视频热更新
      // -----------------------------------------------------------------
      final updateService = _updateService;
      if (updateService != null) {
        unawaited(updateService.checkAndDownloadUpdate());
      }

      final localFile = await updateService?.getValidLocalVideoFile();
      VideoPlayerController? controller;

      if (localFile != null) {
        try {
          AppLogger.debug('使用热更新视频文件: ${localFile.path}', module: 'startup_video_gate');
          controller = VideoPlayerController.file(localFile);
          await controller.initialize();
        } catch (e) {
          AppLogger.warning('加载热更视频失败，降级到 Asset', module: 'startup_video_gate', error: e);
          await controller?.dispose();
          controller = null;
        }
      }

      if (controller == null) {
        controller = VideoPlayerController.asset(_videoAsset);
        await controller.initialize();
      }

      await controller.setLooping(false);
      controller.addListener(_onVideoChanged);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _showVideo = true;
        _isReady = true;
      });
      await _playController(controller);
    } catch (_) {
      _finishWithoutVideo();
    }
  }

  Future<void> _playController(VideoPlayerController controller) async {
    try {
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _autoplayBlocked = true);
    }
  }

  Future<void> _startVideoAfterGesture() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _autoplayBlocked = false);
    await _playController(controller);
  }

  void _onVideoChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.hasError) {
      _finishWithoutVideo();
      return;
    }
    if (controller.value.position >= controller.value.duration) {
      _finishVideo();
    }
  }

  void _finishWithoutVideo() {
    if (!mounted) return;
    setState(() {
      _showVideo = false;
      _isReady = true;
    });
  }

  Future<void> _finishVideo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    await _storage.putString(_lastPlayedVersionKey, currentVersion);

    if (!mounted) return;
    setState(() => _showVideo = false);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || !_showVideo) return widget.child;

    final controller = _controller;
    if (controller == null) return widget.child;

    // This gate wraps MaterialApp, so it cannot rely on MaterialApp's
    // Directionality while the startup video is being displayed.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _autoplayBlocked ? _startVideoAfterGesture : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.black,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(width: controller.value.size.width, height: controller.value.size.height, child: VideoPlayer(controller)),
              ),
            ),
            if (_autoplayBlocked)
              const Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x99000000), borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('点击播放启动视频', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
