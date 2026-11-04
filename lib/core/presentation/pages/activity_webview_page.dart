import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../share/activity_share_message.dart';
import '../../widgets/app_share_sheet.dart';

/// 活动专用 H5 页面，提供 drinkShare JavaScriptChannel，不影响常规 WebView。
class ActivityWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const ActivityWebViewPage({super.key, required this.url, this.title = '活动详情'});

  @override
  State<ActivityWebViewPage> createState() => _ActivityWebViewPageState();
}

class _ActivityWebViewPageState extends State<ActivityWebViewPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  String? _errorMessage;
  bool _isShareSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('drinkShare', onMessageReceived: (message) => _handleDrinkShareMessage(message.message))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _errorMessage = null);
              _injectDrinkShareShim();
            }
          },
          onPageFinished: (_) {
            if (mounted) _injectDrinkShareShim();
          },
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() => _errorMessage = '页面加载失败，请稍后重试');
            }
          },
        ),
      );

    _setupUserAgentAndLoad();
  }

  Future<void> _setupUserAgentAndLoad() async {
    debugPrint('线上活动 WebView 加载 URL: ${widget.url}');
    try {
      final defaultUA = await _controller.getUserAgent();
      final customUA = (defaultUA != null && defaultUA.isNotEmpty) ? '$defaultUA QingQingLife/1.0.0 qqshApp/1.0.0' : 'QingQingLife/1.0.0 qqshApp/1.0.0';
      await _controller.setUserAgent(customUA);
    } catch (_) {
      await _controller.setUserAgent('QingQingLife/1.0.0 qqshApp/1.0.0');
    }
    if (mounted) {
      await _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  void _injectDrinkShareShim() {
    _controller.runJavaScript('''
      (function() {
        window.qqshApp = window.qqshApp || {};
        window.qqshApp.drinkShare = function(data) {
          if (window.drinkShare && window.drinkShare.postMessage) {
            window.drinkShare.postMessage(typeof data === 'string' ? data : JSON.stringify(data));
          }
        };
      })();
    ''');
  }

  Future<void> _handleDrinkShareMessage(String message) async {
    if (!mounted || _isShareSheetOpen) return;
    final decoded = ActivityShareMessage.tryParse(message);
    if (decoded == null || !ActivityShareMessage.isValidWebUrl(decoded.drinkShareUrl) || !ActivityShareMessage.isValidWebUrl(decoded.returnUrl)) {
      return;
    }

    _isShareSheetOpen = true;
    try {
      final payload = decoded.toSharePayload(
        fallbackTitle: widget.title,
        onDrinkShareSucceeded: (returnUrl) {
          if (mounted) _controller.runJavaScript("window.location.href = ${_encodeJsString(returnUrl.toString())};");
        },
      );
      await AppShareSheet.show(context: context, payload: payload);
    } finally {
      _isShareSheetOpen = false;
    }
  }

  String _encodeJsString(String value) => jsonEncode(value);

  Future<void> _reload() async {
    setState(() => _errorMessage = null);
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            if (_loadingProgress < 100 && _errorMessage == null) LinearProgressIndicator(value: _loadingProgress / 100),
          ],
        ),
      ),
    );
  }
}
