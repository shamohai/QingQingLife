import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';

import 'app_link.dart';

/// 接收系统转发的 Schema / Universal Link，并转换为应用内路由。
///
/// 同时覆盖冷启动（App 未运行）和热启动（App 已在前台或后台）两种场景。
class DeepLinkReceiver extends StatefulWidget {
  const DeepLinkReceiver({super.key, required this.onLocation, required this.child});

  /// 收到可用链接后回调应用内路由，例如 `/points/service/12?from=share`。
  final ValueChanged<String> onLocation;

  final Widget child;

  @override
  State<DeepLinkReceiver> createState() => _DeepLinkReceiverState();
}

class _DeepLinkReceiverState extends State<DeepLinkReceiver> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  String? _lastLocation;
  DateTime? _lastHandledAt;

  @override
  void initState() {
    super.initState();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[DeepLink] receive failed: $error');
      },
    );
    // 部分平台在监听建立前就拿到了启动链接，主动读取一次并去重。
    unawaited(_consumeInitialLink());
  }

  Future<void> _consumeInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleLink(uri);
    } catch (error) {
      debugPrint('[DeepLink] read initial link failed: $error');
    }
  }

  void _handleLink(Uri uri) {
    if (!mounted) return;
    final location = AppLink.toAppLocation(uri);
    if (location == null) {
      debugPrint('[DeepLink] ignored unsupported link: $uri');
      return;
    }

    final now = DateTime.now();
    if (_lastLocation == location && _lastHandledAt != null && now.difference(_lastHandledAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastLocation = location;
    _lastHandledAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLocation(location);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
