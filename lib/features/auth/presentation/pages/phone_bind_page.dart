import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/auth_provider.dart';

/// 绑定手机号页（微信授权后补手机号）
///
/// 设计稿来源：蓝湖 lanhu_dengluyeshoujihaobangding
/// 全页背景与登录页一致，复用 assets/images/auth/login_bg.png 与
/// assets/images/auth/login_bottom_deco.png，不使用 AppBar。
/// 业务流复用 AuthNotifier.phoneBind / sendSmsCode。
class PhoneBindPage extends ConsumerStatefulWidget {
  const PhoneBindPage({super.key});

  @override
  ConsumerState<PhoneBindPage> createState() => _PhoneBindPageState();
}

class _PhoneBindPageState extends ConsumerState<PhoneBindPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  int _countdown = 0;
  bool _sending = false;
  bool _submitting = false;
  Timer? _countdownTimer;

  static const Color _buttonBlue = Color(0xFF213775);
  static const Color _linkBlue = Color(0xFF0088FF);
  static const Color _textGray = Color(0xFF8E8E93);
  static const Color _inputBorder = Color(0x1A213775); // #213775 @ 10%

  // 手机号：以 1 开头，后 10 位数字，共 11 位。
  static final RegExp _phoneRegex = RegExp(r'^1\d{10}$');
  // 验证码：6 位数字。
  static final RegExp _codeRegex = RegExp(r'^\d{6}$');

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown <= 1) {
        setState(() => _countdown = 0);
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String? _validatePhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return '请输入手机号';
    if (!_phoneRegex.hasMatch(phone)) return '请输入正确的手机号';
    return null;
  }

  void _sendCode() {
    if (_countdown > 0 || _sending) return;
    final error = _validatePhone();
    if (error != null) {
      _showToast(error);
      return;
    }
    _sending = true;
    _sendSms();
  }

  Future<void> _sendSms() async {
    try {
      final ok = await ref.read(authProvider.notifier).sendSmsCode(phone: _phoneController.text.trim());
      if (!mounted) return;
      if (ok) {
        _startCountdown();
      } else {
        _showToast('验证码发送失败，请稍后重试');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _bindPhone() async {
    if (_submitting) return;
    final phoneError = _validatePhone();
    if (phoneError != null) {
      _showToast(phoneError);
      return;
    }
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showToast('请输入验证码');
      return;
    }
    if (!_codeRegex.hasMatch(code)) {
      _showToast('验证码需为 6 位数字');
      return;
    }
    setState(() => _submitting = true);
    await ref.read(authProvider.notifier).phoneBind(phone: _phoneController.text.trim(), code: code);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (next == AuthStatus.authenticated && previous != AuthStatus.authenticated) {
        if (mounted) context.go(RouteNames.profile);
      }
    });

    final screenW = MediaQuery.sizeOf(context).width;
    final scale = screenW / 440;

    double f(double source, {required double min}) => math.max(source * scale, min);
    final fsTitle = f(36, min: 30);
    final fsLabel = f(20, min: 17);
    final fsInput = f(16, min: 14);
    final fsSend = f(16, min: 14);
    final fsCta = f(18, min: 15);
    final fsAgreement = f(14, min: 12);
    final inputH = f(64, min: 52);
    final ctaH = f(54, min: 44);
    final sidePad = f(48, min: 20);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 顶部背景图（与登录页一致）──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/auth/login_bg.png',
              width: screenW,
              height: screenW * (624 / 440),
              fit: BoxFit.cover,
            ),
          ),

          // ── 底部装饰图（与登录页一致）──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/auth/login_bottom_deco.png',
              width: screenW,
              height: 60,
              fit: BoxFit.fill,
            ),
          ),

          // ── 主内容 ──
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 品牌标题
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, f(40, min: 28), sidePad, 0),
                  child: Text(
                    '欢迎使用\n青轻生活馆',
                    style: TextStyle(
                      fontSize: fsTitle,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.39,
                      letterSpacing: -2,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                // 手机号字段
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, f(56, min: 40), sidePad, 0),
                  child: _buildLabeledInput(label: '手机号', labelSize: fsLabel, inputH: inputH, fsInput: fsInput),
                ),

                // 验证码字段（输入框内含发送验证码）
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, f(24, min: 18), sidePad, 0),
                  child: _buildLabeledCodeInput(
                    labelSize: fsLabel,
                    inputH: inputH,
                    fsInput: fsInput,
                    fsSend: fsSend,
                    sidePad: sidePad,
                  ),
                ),

                // 主按钮
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, f(40, min: 28), sidePad, 0),
                  child: SizedBox(
                    height: ctaH,
                    child: GestureDetector(
                      onTap: _submitting ? null : _bindPhone,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _buttonBlue.withValues(alpha: _submitting ? 0.7 : 1.0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '立即登录',
                          style: TextStyle(fontSize: fsCta, color: Colors.white, height: 1.39),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 底部协议（文案，无 checkbox）
                Padding(
                  padding: EdgeInsets.only(bottom: f(40, min: 28)),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: fsAgreement, color: _textGray, height: 1.17),
                        children: [
                          const TextSpan(text: '登录及接受'),
                          TextSpan(
                            text: '《用户服务协议》',
                            style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '和'),
                          TextSpan(
                            text: '《用户隐私政策》',
                            style: TextStyle(color: _linkBlue, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _inputDeco => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: _inputBorder, width: 1),
  );

  /// 手机号输入（label + 白色圆角输入框）。
  Widget _buildLabeledInput({
    required String label,
    required double labelSize,
    required double inputH,
    required double fsInput,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 14),
        SizedBox(
          height: inputH,
          child: Container(
            decoration: _inputDeco,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              style: TextStyle(fontSize: fsInput, color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                hintText: '请输入手机号',
                hintStyle: TextStyle(fontSize: fsInput, color: _textGray),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 验证码输入（label + 白色圆角输入框，框内右侧为发送验证码）。
  Widget _buildLabeledCodeInput({
    required double labelSize,
    required double inputH,
    required double fsInput,
    required double fsSend,
    required double sidePad,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('验证码', style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 14),
        SizedBox(
          height: inputH,
          child: Container(
            decoration: _inputDeco,
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: const TextInputType.numberWithOptions(signed: false),
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: TextStyle(fontSize: fsInput, color: Colors.black),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '请输入验证码',
                      hintStyle: TextStyle(fontSize: fsInput, color: _textGray),
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _countdown > 0 || _sending ? null : _sendCode,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad * 0.25),
                    child: Text(
                      _countdown > 0 ? '${_countdown}s' : '发送验证码',
                      style: TextStyle(
                        fontSize: fsSend,
                        fontWeight: FontWeight.w500,
                        color: _countdown > 0 || _sending ? _textGray : _linkBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
