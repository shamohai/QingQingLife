import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';

/// 链接分发失败兜底页。
///
/// 分发逻辑本身在 [AppLink.dispatchRedirect] 中完成，由 GoRouter 的全局
/// `redirect` 在路由匹配阶段直接跳到目标页面，正常链接不会渲染本页。
/// 因此本页只会在 `route` 参数缺失或目标路由不合法时出现，是一个纯展示页面。
class LinkDispatchPage extends StatelessWidget {
  const LinkDispatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B4696),
        body: SafeArea(
          child: Center(
            child: Padding(
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
                  const Text('请返回原入口重新打开链接', style: TextStyle(fontSize: 13, color: Colors.white70)),
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
