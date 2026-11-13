import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:qingqinglife/core/location/activity_location_service.dart';
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
  WebViewController? _controller;
  int _loadingProgress = 0;
  String? _errorMessage;
  bool _isShareSheetOpen = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Web 端 webview_flutter 未实现 JS Channel 等接口，改为拼接后用新窗口打开。
      _openOnWeb();
      return;
    }
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

  /// 构造最终 URL（与移动端逻辑一致），Web 端仅打印并在新窗口打开。
  /// 微盟活动需要 SSO 参数：获取失败时返回 null 并展示错误，不再带着空 token 加载 H5。
  Future<String?> _buildFinalUrl() async {
    var finalUrl = widget.url;
    final actType = widget.activityType?.trim().toLowerCase();
    debugPrint('[线上活动] 原始URL (activityType=$actType): ${widget.url}');
    if (actType == 'drinkmapactivity' || actType == 'drinkrankactivity') {
      final response = await ref.read(activityLocationServiceProvider).getWeimengActivityLocation();
      if (!response.success || response.data == null) {
        final message = response.message.isNotEmpty ? response.message : '获取活动信息失败，请稍后重试';
        debugPrint('[线上活动] 获取微盟 SSO 参数失败: code=${response.code}, message=$message');
        if (mounted) setState(() => _errorMessage = message);
        return null;
      }
      final baseUri = Uri.tryParse(widget.url);
      if (baseUri != null) {
        final isDrinkMap = actType == 'drinkmapactivity';
        final builtUri = buildWeimengActivityUri(baseUri, response.data!, includeArea: isDrinkMap);
        finalUrl = builtUri.toString();
      }
    }
    debugPrint('[线上活动] 拼接后最终WebView URL: $finalUrl');
    return finalUrl;
  }

  Future<void> _openOnWeb() async {
    final finalUrl = await _buildFinalUrl();
    if (!mounted || finalUrl == null) return;
    await launchUrl(Uri.parse(finalUrl), webOnlyWindowName: '_blank');
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _setupUserAgentAndLoad() async {
    final controller = _controller;
    if (controller == null) return;
    final finalUrl = await _buildFinalUrl();
    if (finalUrl == null) return;
    AppLogger.debug('线上活动 WebView 加载 URL: $finalUrl', module: 'activity_webview');
    try {
      final defaultUA = await controller.getUserAgent();
      final customUA = (defaultUA != null && defaultUA.isNotEmpty) ? '$defaultUA QingQingLife/1.0.0 qqshApp/1.0.0' : 'QingQingLife/1.0.0 qqshApp/1.0.0';
      await controller.setUserAgent(customUA);
    } catch (_) {
      await controller.setUserAgent('QingQingLife/1.0.0 qqshApp/1.0.0');
    }
    if (mounted) {
      await controller.loadRequest(Uri.parse(finalUrl));
    }
  }

  Future<void> _handleShareMessage(String message) async {
    final controller = _controller;
    if (!mounted || _isShareSheetOpen || controller == null) return;
    final shareMessage = ActivityShareMessage.tryParse(message);
    if (shareMessage == null) return;

    _isShareSheetOpen = true;
    try {
      final currentUrl = await controller.currentUrl();
      if (!mounted) return;
      final payload = shareMessage.toSharePayload(fallbackTitle: widget.title, fallbackUrl: currentUrl);
      await AppShareSheet.show(context: context, payload: payload);
    } finally {
      _isShareSheetOpen = false;
    }
  }

  Future<void> _reload() async {
    final controller = _controller;
    if (controller == null) {
      await _openOnWeb();
      return;
    }
    setState(() => _errorMessage = null);
    // 首次 SSO 参数获取失败时页面尚未加载，reload 无效，需重新构造 URL 加载
    await _setupUserAgentAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))],
      ),
      body: kIsWeb || controller == null
          ? const Center(child: Text('已在新窗口打开活动页面'))
          : SafeArea(
              top: false,
              bottom: true,
              child: Stack(
                children: [
                  if (_errorMessage == null) WebViewWidget(controller: controller),
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
