import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/auth_provider.dart';

/// 登录页（微信授权）
///
/// 设计稿来源：蓝湖 lanhu_dengluye / lanhu_dengluyeweixinshouquan
/// 两个状态：
///   1. 正常状态：白底 + 背景图 + 标题 + 微信图标 + 授权按钮 + 协议勾选 + 底部装饰
///   2. 协议弹窗：半透明遮罩 + 底部白色圆角面板（"请阅读并同意以下条款"）
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _agreed = false;
  bool _showAgreementSheet = false;
  bool _showLoading = false;

  // ── 设计稿色值 ─────────────────────────────────────────────────────
  static const Color _buttonBlue = Color(0xFF213775);
  static const Color _linkBlue = Color(0xFF0088FF);
  static const Color _textGray = Color(0xFF8E8E93);

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
    _doWechatLogin();
  }

  void _onCloseSheet() {
    setState(() => _showAgreementSheet = false);
  }

  void _doWechatLogin() {
    setState(() => _showLoading = true);
    ref.read(authProvider.notifier).wechatLogin();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (previous == AuthStatus.loading && next == AuthStatus.wechatAuthenticated) {
        if (mounted) context.push(RouteNames.phoneBind);
      } else if (previous == AuthStatus.loading && next == AuthStatus.authenticated) {
        if (mounted) context.go(RouteNames.profile);
      } else if (next == AuthStatus.unauthenticated) {
        if (mounted) setState(() => _showLoading = false);
      }
    });

    final screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 背景图（顶部区域）──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/auth/login_bg.png', width: screenW, height: screenW * (624 / 440), fit: BoxFit.cover),
          ),

          // ── 底部装饰图 ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/auth/login_bottom_deco.png', width: screenW, height: 60, fit: BoxFit.fill),
          ),

          // ── 主内容 ──
          Padding(padding: const EdgeInsets.only(top: 103), child: _buildMainContent()),

          // ── 协议弹窗（遮罩 + 底部面板）──
          if (_showAgreementSheet) ...[
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.3))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                padding: const EdgeInsets.only(bottom: 32),
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
                    const SizedBox(height: 12),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, height: 1.0),
                          children: [
                            TextSpan(
                              text: '《用户服务协议》',
                              style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500, letterSpacing: -2),
                            ),
                            TextSpan(
                              text: '和',
                              style: TextStyle(color: _textGray, letterSpacing: -2),
                            ),
                            TextSpan(
                              text: '《用户隐私政策》',
                              style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500, letterSpacing: -2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // "同意并继续" 按钮
                    const SizedBox(height: 24),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 46), child: _buildAuthButton('同意并继续', _onAgreeAndContinue)),
                  ],
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
  Widget _buildMainContent() {
    const double contentHeight = 100.0 + 60 + 54 + 28;
    const double designGap = 60.0 + 44 + 15;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxHeight - contentHeight;
        final double scale = available <= 0 ? 0 : math.min(1.0, available / designGap);
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 42),
              child: Text(
                '欢迎使用\n青轻生活馆',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: Colors.black, height: 1.39, letterSpacing: -2),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 60 * scale),
            // 微信圆形图标
            Image.asset('assets/images/auth/icon_wechat.png', width: 60, height: 60),
            SizedBox(height: 44 * scale),
            // "微信一键授权" 按钮
            Padding(padding: const EdgeInsets.symmetric(horizontal: 46), child: _buildAuthButton('微信一键授权', _onWechatAuth)),
            SizedBox(height: 15 * scale),
            // 协议文本（可勾选）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 46),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
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
                            style: const TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '和'),
                          TextSpan(
                            text: '《用户隐私政策》',
                            style: const TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '，未注册的手机号验证后将自动创建青轻生活馆账号。'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 设计稿统一授权按钮（#213775, 圆角 6px, 白色 18px 文字, 高 54px）
  Widget _buildAuthButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(color: _buttonBlue, borderRadius: BorderRadius.circular(6)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.39)),
      ),
    );
  }
}
