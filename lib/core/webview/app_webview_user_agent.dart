import 'package:webview_flutter/webview_flutter.dart';

/// App 内 WebView 的 UA 标识，H5 侧据此识别运行在青轻生活 App 中。
const String kAppUserAgentSuffix = 'QingQingLife/1.0.0 qqshApp/1.0.0';

/// 在系统默认 UA 后追加 App 标识。
///
/// 已包含标识时不再追加，保证同一个 controller 多次调用（如页面 reload）不会重复拼接。
Future<void> applyAppUserAgent(WebViewController controller) async {
  String baseUa = '';
  try {
    baseUa = await controller.getUserAgent() ?? '';
  } catch (_) {
    // 获取失败时只设置标识，不阻断页面加载。
  }
  if (baseUa.contains(kAppUserAgentSuffix)) return;

  final ua = baseUa.isEmpty ? kAppUserAgentSuffix : '$baseUa $kAppUserAgentSuffix';
  await controller.setUserAgent(ua);
}
