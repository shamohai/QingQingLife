import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../share/activity_share_message.dart';
import '../../webview/app_webview_user_agent.dart';
import '../../widgets/app_share_sheet.dart';

/// App 内 H5 页面。
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, this.title = '活动详情'});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  String? _errorMessage;
  bool _isShareSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('AppShare', onMessageReceived: (message) => _handleShareMessage(message.message))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (mounted) setState(() => _loadingProgress = progress);
            },
            onPageStarted: (_) {
              if (mounted) setState(() => _errorMessage = null);
            },
            onWebResourceError: (error) {
              if (mounted && error.isForMainFrame == true) {
                setState(() => _errorMessage = '页面加载失败，请稍后重试');
              }
            },
          ),
        );
    }
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (!kIsWeb) await applyAppUserAgent(_controller);
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  /// 与活动页 AppShare 协议一致：H5 传入 JSON 字符串，缺省字段回退到当前页面信息。
  Future<void> _handleShareMessage(String message) async {
    if (!mounted || _isShareSheetOpen) return;
    final shareMessage = ActivityShareMessage.tryParse(message);
    if (shareMessage == null) return;

    _isShareSheetOpen = true;
    try {
      final currentUrl = await _controller.currentUrl();
      if (!mounted) return;
      final payload = shareMessage.toSharePayload(fallbackTitle: widget.title, fallbackUrl: currentUrl);
      await AppShareSheet.show(context: context, payload: payload);
    } finally {
      _isShareSheetOpen = false;
    }
  }

  Future<void> _reload() async {
    if (kIsWeb) {
      await _controller.loadRequest(Uri.parse(widget.url));
      return;
    }
    setState(() => _errorMessage = null);
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.title),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            if (_errorMessage == null) WebViewWidget(controller: _controller),
            if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _reload, child: const Text('重新加载')),
                  ],
                ),
              ),
            if (!kIsWeb && _loadingProgress < 100 && _errorMessage == null) LinearProgressIndicator(value: _loadingProgress / 100),
          ],
        ),
      ),
    );
  }
}
