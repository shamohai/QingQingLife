import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:qingqinglife/core/providers/repository_providers.dart';
import 'package:qingqinglife/features/home/data/models/weimeng_activity_location.dart';

import '../../../core/logging/app_logger.dart';
import '../../share/activity_share_message.dart';
import '../../widgets/app_share_sheet.dart';

/// 活动专用 H5 页面，提供 AppShare JavaScriptChannel，不影响常规 WebView。
class ActivityWebViewPage extends ConsumerStatefulWidget {
  final String url;
  final String title;
  final String? activityType;

  const ActivityWebViewPage({super.key, required this.url, this.title = '活动详情', this.activityType});

  @override
  ConsumerState<ActivityWebViewPage> createState() => _ActivityWebViewPageState();
}

class _ActivityWebViewPageState extends ConsumerState<ActivityWebViewPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  String? _errorMessage;
  bool _isShareSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
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

    _setupUserAgentAndLoad();
  }

  Future<void> _setupUserAgentAndLoad() async {
    var finalUrl = widget.url;
    final actType = widget.activityType?.trim().toLowerCase();
    if (actType == 'drinkmapactivity' || actType == 'drinkrankactivity') {
      try {
        final response = await ref.read(productRepositoryProvider).getWeimengActivityLocation();
        if (response.success && response.data != null) {
          final baseUri = Uri.tryParse(widget.url);
          if (baseUri != null) {
            final isDrinkMap = actType == 'drinkmapactivity';
            final builtUri = buildWeimengActivityUri(baseUri, response.data!, includeArea: isDrinkMap);
            finalUrl = builtUri.toString();
          }
        }
      } catch (_) {
        // Fallback to original url if fetching location fails
      }
    }

    AppLogger.debug('线上活动 WebView 加载 URL: $finalUrl', module: 'activity_webview');
    try {
      final defaultUA = await _controller.getUserAgent();
      final customUA = (defaultUA != null && defaultUA.isNotEmpty) ? '$defaultUA QingQingLife/1.0.0 qqshApp/1.0.0' : 'QingQingLife/1.0.0 qqshApp/1.0.0';
      await _controller.setUserAgent(customUA);
    } catch (_) {
      await _controller.setUserAgent('QingQingLife/1.0.0 qqshApp/1.0.0');
    }
    if (mounted) {
      await _controller.loadRequest(Uri.parse(finalUrl));
    }
  }

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
