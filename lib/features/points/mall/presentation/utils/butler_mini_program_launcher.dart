import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/butler_mini_program_provider.dart';

const _miniProgramUsername = 'gh_c55d2ab30511';

Future<void> launchButlerMiniProgram(BuildContext context, WidgetRef ref, {String serviceName = ''}) async {
  final resolvedServiceName = serviceName.trim().isEmpty ? '管家服务' : serviceName.trim();
  try {
    final info = await ref.read(butlerMiniProgramInfoProvider.future);
    if (!context.mounted) return;
    final path = info?.workwxmppath.trim() ?? '';
    await launchMiniProgramPath(
      context,
      path: path,
      serviceName: resolvedServiceName,
    );
  } catch (_) {
    if (!context.mounted) return;
    _showMessage(context, '打开$resolvedServiceName失败，请稍后重试');
  }
}

Future<void> launchMiniProgramPath(
  BuildContext context, {
  required String path,
  required String serviceName,
  String? fallbackPhone,
}) async {
  String withFallback(String message) {
    final phone = fallbackPhone?.trim() ?? '';
    return phone.isEmpty ? message : '$message，可拨打备用电话 $phone';
  }

  final miniProgramPath = path.trim();
  if (miniProgramPath.isEmpty) {
    _showMessage(context, withFallback('暂无法获取$serviceName入口，请稍后重试'));
    return;
  }

  try {
    final weChat = fluwx.Fluwx();
    final isInstalled = await weChat.isWeChatInstalled;
    if (!context.mounted) return;

    if (!isInstalled) {
      _showMessage(context, withFallback('请先安装微信，再使用$serviceName'));
      return;
    }

    final opened = await weChat.open(
      target: fluwx.MiniProgram(username: _miniProgramUsername, path: miniProgramPath),
    );
    if (!opened && context.mounted) {
      _showMessage(context, withFallback('打开$serviceName失败，请稍后重试'));
    }
  } catch (_) {
    if (!context.mounted) return;
    _showMessage(context, withFallback('打开$serviceName失败，请稍后重试'));
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
