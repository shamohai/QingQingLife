import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import 'app_link.dart';

/// App 内统一链接接收页。
///
/// 读取 `route` 和其余 query 参数，校验目标路由后再跳转。
class LinkReceivePage extends StatefulWidget {
  const LinkReceivePage({super.key, required this.queryParameters});

  final Map<String, String> queryParameters;

  @override
  State<LinkReceivePage> createState() => _LinkReceivePageState();
}

class _LinkReceivePageState extends State<LinkReceivePage> {
  String? _targetLocation;
  bool _dispatched = false;

  @override
  void initState() {
    super.initState();
    _targetLocation = AppLink.resolveDispatchTarget(widget.queryParameters);
    WidgetsBinding.instance.addPostFrameCallback((_) => _dispatch());
  }

  void _dispatch() {
    if (!mounted || _dispatched) return;
    final target = _targetLocation;
    if (target == null) return;
    _dispatched = true;
    context.replace(target);
  }

  @override
  Widget build(BuildContext context) {
    final valid = _targetLocation != null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B4696),
        body: SafeArea(
          child: Center(
            child: valid
                ? const CircularProgressIndicator(color: Colors.white)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link_off, size: 44, color: Colors.white70),
                        const SizedBox(height: 16),
                        const Text(
                          '链接无效或已失效',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text('请返回 App 重新获取分享链接', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 160,
                          height: 42,
                          child: FilledButton(
                            onPressed: () => context.go(RouteNames.home),
                            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1F3B82)),
                            child: const Text('返回首页'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
