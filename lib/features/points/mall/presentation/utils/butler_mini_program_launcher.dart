import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/butler_mini_program_provider.dart';

const _miniProgramUsername = 'gh_c55d2ab30511';

Future<void> launchButlerMiniProgram(BuildContext context, WidgetRef ref) async {
  try {
    final info = await ref.read(butlerMiniProgramInfoProvider.future);
    if (!context.mounted) return;
    final path = info?.workwxmppath.trim() ?? '';
    if (path.isEmpty) {
      _showMessage(context, '暂无法获取管家服务入口，请稍后重试');
      return;
    }

    final weChat = fluwx.Fluwx();
    final isInstalled = await weChat.isWeChatInstalled;
    if (!context.mounted) return;

    if (!isInstalled) {
      _showMessage(context, '请先安装微信后再使用管家服务');
      return;
    }

    await weChat.open(
      target: fluwx.MiniProgram(username: _miniProgramUsername, path: path),
    );
  } catch (_) {
    if (!context.mounted) return;
    _showMessage(context, '打开管家服务失败，请稍后重试');
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
