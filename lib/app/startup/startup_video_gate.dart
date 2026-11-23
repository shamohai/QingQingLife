import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/logging/app_logger.dart';
import '../../core/storage/local_storage.dart';
import '../../core/update/services/startup_video_update_service_stub.dart' if (dart.library.io) '../../core/update/services/startup_video_update_service.dart';

/// Controls the one-time startup video shown after an install or app upgrade.
class StartupVideoGate extends StatefulWidget {
  const StartupVideoGate({required this.child, this.onReady, super.key});

  final Widget child;

  /// 启动视频结束（或无需播放）后回调，此时 MaterialApp 已挂载，可以安全弹出全局弹窗
  final VoidCallback? onReady;

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

  /// 本次播放所用视频对应的版本标记（在开始播放时确定，避免后台下载完成后被误记为已播放）
  String _playedVersionKey = '';

  @override
  void initState() {
    super.initState();
    _updateService = StartupVideoUpdateService();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final lastPlayedVersion = await _storage.getString(_lastPlayedVersionKey);
      final localMd5 = await _storage.getString('startup_video_local_md5') ?? '';
      final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}_$localMd5';
      _playedVersionKey = currentVersion;

      if (!mounted || lastPlayedVersion == currentVersion) {
        _finishWithoutVideo();
        return;
      }

      // 热更新下载由 bootstrap 在启动时后台触发，此处只读取本地已下载的视频；
      // Web 上 stub 返回 null，自动回退到内置 Asset 视频。
      final localFile = await _updateService?.getValidLocalVideoFile();
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
      // Web 浏览器会阻止有声自动播放，先静音再播放；原生端保持原音量。
      if (kIsWeb) {
        await controller.setVolume(0);
      }
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
    widget.onReady?.call();
  }

  Future<void> _finishVideo() async {
    // 记录的是开始播放时的版本标记：若后台热更新在播放期间完成，下次打开会因 MD5 变化而重新播放
    if (_playedVersionKey.isNotEmpty) {
      try {
        await _storage.putString(_lastPlayedVersionKey, _playedVersionKey);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _showVideo = false);
    widget.onReady?.call();
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
