import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/storage/local_storage.dart';

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
  VideoPlayerController? _controller;
  bool _showVideo = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
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
      await controller.play();
    } catch (_) {
      _finishWithoutVideo();
    }
  }

  void _onVideoChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
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
        ],
      ),
    );
  }
}
