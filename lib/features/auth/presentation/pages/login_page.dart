import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/auth_redirect.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/analytics/umeng_analytics.dart';
import '../../../../core/storage/device_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/auth_provider.dart';

/// 登录页（微信授权）
///
/// 设计稿来源：蓝湖 lanhu_dengluye / lanhu_dengluyeweixinshouquan
/// 两个状态：
///   1. 正常状态：白底 + 背景图 + 标题 + 微信图标 + 授权按钮 + 协议勾选 + 底部装饰
///   2. 协议弹窗：半透明遮罩 + 底部白色圆角面板（"请阅读并同意以下条款"）
///
/// Web 环境下额外提供测试登录区：手动填写设备 ID 与 authtoken 模拟登录，
/// 与微信授权登录写入同一份本地登录态（accessToken / authtoken / devid）。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _agreed = false;
  bool _showAgreementSheet = false;
  bool _showLoading = false;

  // Web 测试登录输入（仅 kIsWeb 使用）
  final _deviceIdController = TextEditingController();
  final _authTokenController = TextEditingController();
  final SecureStorage _storage = SecureStorage();

  /// 联调默认值，与原 token-debug 页保持一致。
  static const String _defaultTestAuthToken = '1575474';
  static const String _defaultTestDeviceId = '17835616055244338';

  // ── 设计稿色值 ─────────────────────────────────────────────────────
  static const Color _buttonBlue = Color(0xFF213775);
  static const Color _linkBlue = Color(0xFF0088FF);
  static const Color _textGray = Color(0xFF8E8E93);

  /// 协议链接点击识别器，dispose 时释放。
  late final TapGestureRecognizer _serviceAgreementTap = TapGestureRecognizer()..onTap = () => _openAgreement(RouteNames.userServiceAgreementUrl, '用户服务协议');
  late final TapGestureRecognizer _privacyPolicyTap = TapGestureRecognizer()..onTap = () => _openAgreement(RouteNames.userPrivacyPolicyUrl, '用户隐私政策');

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _loadSavedLoginValues();
  }

  /// 回填本地已保存的登录信息，便于直接复用上次联调的身份。
  Future<void> _loadSavedLoginValues() async {
    final authToken = await _storage.readAuthToken() ?? '';
    final savedDeviceId = await _storage.readDeviceId() ?? '';
    final deviceId = savedDeviceId.isNotEmpty ? savedDeviceId : await DeviceStorage.getDeviceId();
    if (!mounted) return;
    _authTokenController.text = authToken;
    _deviceIdController.text = deviceId;
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _authTokenController.dispose();
    _serviceAgreementTap.dispose();
    _privacyPolicyTap.dispose();
    super.dispose();
  }

  void _onWechatAuth() {
    if (!_agreed) {
      setState(() => _showAgreementSheet = true);
      return;
    }
    _doWechatLogin();
  }

  void _onAgreeAndContinue() {
    setState(() {
      _agreed = true;
      _showAgreementSheet = false;
    });
    _recordPrivacyAccepted();
    _doWechatLogin();
  }

  /// 用户在登录页同意《用户隐私政策》后，才允许初始化友盟统计。
  void _recordPrivacyAccepted() {
    unawaited(ref.read(umengAnalyticsProvider).onPrivacyAccepted());
  }

  void _onCloseSheet() {
    setState(() => _showAgreementSheet = false);
  }

  /// 打开协议 H5 页面（与“我的-关于我们”使用同一 WebView 路由）。
  Future<void> _openAgreement(String url, String title) async {
    final route = Uri(path: RouteNames.webView, queryParameters: {'url': url, 'title': title});
    await context.push(route.toString());
  }

  void _doWechatLogin() {
    setState(() => _showLoading = true);
    _listenLoginResultOnce();
    ref.read(authProvider.notifier).wechatLogin();
  }

  /// 本次登录只注册一次结果监听，成功或失败后立即释放。
  ///
  /// 不放在 [build] 里的 ref.listen：build 会多次执行，监听可能重复注册，
  /// 导致登录成功后跳转被执行多次，页面叠在栈里停留在登录页。
  void _listenLoginResultOnce() {
    late final ProviderSubscription<AuthStatus> subscription;
    subscription = ref.listenManual<AuthStatus>(authProvider, (previous, next) {
      if (next == AuthStatus.authenticated) {
        subscription.close();
        if (mounted) _goAfterLogin();
      } else if (next == AuthStatus.unauthenticated) {
        subscription.close();
        if (mounted) setState(() => _showLoading = false);
      }
    });
  }

  /// 登录成功后回到来源页。
  ///
  /// 登录页通常是从其他页面 push 进来的，此时 pop 可以保留原有路由栈（首页 → 详情页），
  /// 详情页的后退才能回到首页。只有没有可 pop 的页面（如被路由重定向进入）时，
  /// 才使用 go 跳转到 from 或"我的"页。
  void _goAfterLogin() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final returnTo = safeReturnTo(GoRouterState.of(context).uri.queryParameters['from']);
    context.go(returnTo ?? RouteNames.profile);
  }

  /// Web 测试登录：使用输入的 authtoken + devid 模拟微信授权登录成功后的结果。
  void _doWebTestLogin() {
    final authToken = _authTokenController.text.trim();
    final deviceId = _deviceIdController.text.trim();
    if (authToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 authtoken')));
      return;
    }
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入设备 ID')));
      return;
    }
    setState(() => _showLoading = true);
    _listenLoginResultOnce();
    ref.read(authProvider.notifier).webTestLogin(authToken: authToken, deviceId: deviceId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (previous == AuthStatus.loading && next == AuthStatus.wechatAuthenticated) {
        if (mounted) {
          final from = safeReturnTo(GoRouterState.of(context).uri.queryParameters['from']);
          final phoneBindLocation = from == null ? RouteNames.phoneBind : Uri(path: RouteNames.phoneBind, queryParameters: {'from': from}).toString();
          context.push(phoneBindLocation);
        }
      } else if (next == AuthStatus.unauthenticated) {
        if (mounted) setState(() => _showLoading = false);
      }
    });

    final screenW = MediaQuery.sizeOf(context).width;
    // final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    // 只需要键盘高度，系统导航栏交给 SafeArea
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    // 用 viewPadding.bottom（系统导航栏） + viewInsets.bottom（键盘）
    //final bottomSafe = MediaQuery.viewPaddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 背景图（顶部区域）──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/auth/login_bg.png', width: screenW, height: screenW * (896 / 440), fit: BoxFit.cover),
          ),

          // ── 底部装饰图 ──
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset('assets/images/auth/login_bottom_deco.png', width: screenW, height: 60, fit: BoxFit.fill),
          // ),

          // ── 主内容 ──
          Padding(padding: const EdgeInsets.only(top: 80), child: _buildMainContent()),

          // ── 协议弹窗（遮罩 + 底部面板）──
          if (_showAgreementSheet) ...[
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.3))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                // 自动处理底部导航栏
                top: false,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  padding: EdgeInsets.only(bottom: 15 + keyboardBottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题行："请阅读并同意以下条款" + 关闭 X
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            const Spacer(),
                            const Text(
                              '请阅读并同意以下条款',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                            const Spacer(),
                            GestureDetector(onTap: _onCloseSheet, child: Image.asset('assets/images/auth/icon_close.png', width: 24, height: 24)),
                          ],
                        ),
                      ),
                      // 协议链接
                      const SizedBox(height: 6),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 15, height: 1.0),
                            children: [
                              TextSpan(
                                text: '《用户服务协议》',
                                recognizer: _serviceAgreementTap,
                                style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500, letterSpacing: -2),
                              ),
                              TextSpan(
                                text: '和',
                                style: TextStyle(color: _textGray, letterSpacing: -2),
                              ),
                              TextSpan(
                                text: '《用户隐私政策》',
                                recognizer: _privacyPolicyTap,
                                style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500, letterSpacing: -2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // "同意并继续" 按钮
                      const SizedBox(height: 44),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 46), child: _buildAuthButton('同意并继续', _onAgreeAndContinue)),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ── 授权 loading 遮罩 ──
          if (_showLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(child: AppLoading()),
              ),
            ),
        ],
      ),
    );
  }

  /// 主内容列。
  ///
  /// 内容固有高度约 242（标题两行≈100 + 图标 60 + 按钮 54 + 协议行≈28），
  /// 设计间距合计 119（60/44/15）。屏幕高度不足时按比例压缩间距，
  /// 避免 Column 溢出；标准屏幕保持设计稿间距不变。
  ///
  /// 大间距（heroGap）必须同时受剩余空间限制（Web 还要扣除测试登录区高度），
  /// 且整体在所有平台都可滚动，兜底真机小屏 / 系统导航栏占用导致的 bottom overflow。
  Widget _buildMainContent() {
    const double contentHeight = 100.0 + 60 + 54 + 28;
    const double designGap = 60.0 + 44 + 15;
    // Web 测试登录区预留高度（标题 + 两个输入框 + 按钮 + 间距）
    const double webTestPanelHeight = 200.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxHeight - contentHeight;
        final double scale = (available <= 0 || !available.isFinite) ? 0 : math.min(1.0, available / designGap);
        final double panelHeight = kIsWeb ? webTestPanelHeight : 0;
        final double heroGap = math.max(0, math.min(470 * scale, available - panelHeight));
        final column = Column(
          children: [
            const Center(
              child: Text(
                '青轻生活馆',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.39,
                  // 注意：过大的负数 letterSpacing 可能会导致文本在居中时视觉上稍微偏左
                  letterSpacing: -2,
                ),
                textAlign: TextAlign.center, // 将对齐方式改为 center
              ),
            ),
            SizedBox(height: 10 * scale),
            const Center(
              child: Text(
                '青轻从一杯开始',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white, height: 1.39, letterSpacing: -2),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: heroGap),
            // 微信圆形图标
            Image.asset('assets/images/auth/icon_wechat.png', width: 56, height: 56),
            SizedBox(height: 28 * scale),
            // "微信一键授权" 按钮
            Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: _buildAuthButton('微信一键授权', _onWechatAuth)),
            SizedBox(height: 15 * scale),
            // 协议文本（可勾选）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (v) {
                      setState(() => _agreed = v ?? false);
                      if (_agreed) _recordPrivacyAccepted();
                    },
                    shape: const CircleBorder(),
                    visualDensity: VisualDensity.compact,
                    activeColor: _linkBlue,
                    side: const BorderSide(color: _textGray),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: _textGray, height: 1.17, letterSpacing: -2),
                        children: [
                          const TextSpan(text: '登录即代表您已同意'),
                          TextSpan(
                            text: '《用户服务协议》',
                            recognizer: _serviceAgreementTap,
                            style: const TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '和'),
                          TextSpan(
                            text: '《用户隐私政策》',
                            recognizer: _privacyPolicyTap,
                            style: const TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '，未注册的手机号验证后将自动创建青轻生活账号。'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Web 环境测试入口：仅 kIsWeb 可见，不使用设计稿色值，低视觉权重
            // if (kIsWeb)
            _buildWebTestLoginPanel(),
          ],
        );

        // 允许滚动，避免小视口、键盘弹出或真机系统导航栏占位时溢出；至少撑满可用高度。
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: column,
          ),
        );
      },
    );
  }

  /// Web 测试登录区：手动填写设备 ID 与 authtoken 模拟登录。
  ///
  /// 仅用于 Web 联调，独立于设计稿样式，视觉权重低于微信授权按钮。
  Widget _buildWebTestLoginPanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Web 测试登录', style: TextStyle(fontSize: 12, color: _textGray)),
          const SizedBox(height: 8),
          TextField(
            controller: _deviceIdController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              labelText: '设备 ID',
              labelStyle: TextStyle(fontSize: 12, color: _textGray),
              hintText: '请输入设备 ID',
              hintStyle: TextStyle(fontSize: 12, color: _textGray),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _authTokenController,
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _doWebTestLogin(),
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'authtoken',
              labelStyle: TextStyle(fontSize: 12, color: _textGray),
              hintText: '请输入 authtoken',
              hintStyle: TextStyle(fontSize: 12, color: _textGray),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _doWebTestLogin,
                child: const Text(
                  'Web 登录',
                  style: TextStyle(fontSize: 12, color: Color(0x990088FF), decoration: TextDecoration.underline),
                ),
              ),
              TextButton(
                onPressed: _fillDefaultTestLoginValues,
                child: const Text('填入联调默认值', style: TextStyle(fontSize: 12, color: Color(0x990088FF))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 回填联调默认值（原 token-debug 页提供的快捷入口，仅 Web 使用）。
  void _fillDefaultTestLoginValues() {
    setState(() {
      _authTokenController.text = _defaultTestAuthToken;
      _deviceIdController.text = _defaultTestDeviceId;
    });
  }

  /// 设计稿统一授权按钮（#213775, 圆角 6px, 白色 18px 文字, 高 54px）
  Widget _buildAuthButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: _buttonBlue, borderRadius: BorderRadius.circular(36)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.39)),
      ),
    );
  }
}
