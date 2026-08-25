import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  int _countdown = 0;
  bool _sliderDone = false;
  String _errorMsg = '';
  bool _showError = false;
  static const _carrier = '+86';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    Future.doWhile(() async {
      if (_countdown <= 1) {
        setState(() => _countdown = 0);
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _countdown--);
      return true;
    });
  }

  void _sendCode() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showToast('请输入手机号');
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _showToast('请输入正确的手机号');
      return;
    }
    if (!_sliderDone) {
      setState(() {
        _showError = true;
        _errorMsg = '请先完成滑块验证';
      });
      return;
    }
    _startCountdown();
    debugPrint('[Login] send code');
  }

  void _wechatLogin() {
    ref.read(authProvider.notifier).wechatLogin();
  }

  void _phoneLogin() {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.isEmpty) {
      _showToast('请输入手机号');
      return;
    }
    if (code.isEmpty) {
      _showToast('请输入验证码');
      return;
    }
    if (!_sliderDone) {
      _showToast('请先完成滑块验证');
      return;
    }
    ref.read(authProvider.notifier).phoneLogin();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听认证状态变化，登录成功后跳转到"我的"页面
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (previous == AuthStatus.loading && next == AuthStatus.authenticated) {
        if (mounted) {
          context.go(RouteNames.profile);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(Icons.eco, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '青轻生活馆',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '健康生活，轻享品质',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Phone input row
              Row(
                children: [
                  Text(_carrier, style: AppTextStyles.labelMedium),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: '请输入手机号',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 96,
                    child: OutlinedButton(
                      onPressed: _sendCode,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: _countdown > 0
                          ? Text('', style: AppTextStyles.labelMedium)
                          : const Text('获取验证码'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Verification code input
              TextField(
                controller: _codeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                ),
                maxLength: 6,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: '请输入验证码',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_showError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    _errorMsg,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              // Slider captcha
              _SliderCaptcha(
                done: _sliderDone,
                onDone: () {
                  setState(() => _sliderDone = true);
                  setState(() => _showError = false);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _phoneLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('登录', style: AppTextStyles.labelLarge),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Agreement text
              Text(
                '登录即代表同意《用户服务协议》《用户隐私政策》',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '未注册手机号验证后将自动创建账号',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              // WeChat login
              _WeChatLoginButton(onPressed: _wechatLogin),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderCaptcha extends StatefulWidget {
  final bool done;
  final VoidCallback onDone;
  const _SliderCaptcha({required this.done, required this.onDone});
  @override
  State<_SliderCaptcha> createState() => _SliderCaptchaState();
}

class _SliderCaptchaState extends State<_SliderCaptcha> {
  double _x = 0;
  bool _dragging = false;
  static const _thumbSize = 40.0;
  static const _trackWidth = 280.0;

  void _onStart(DragStartDetails d) {
    if (!widget.done) setState(() => _dragging = true);
  }

  void _onUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    setState(() {
      _x = (_x + d.delta.dx).clamp(0, _trackWidth - _thumbSize);
    });
  }

  void _onEnd(DragEndDetails d) {
    if (!_dragging) return;
    setState(() => _dragging = false);
    if (_x >= _trackWidth - _thumbSize - 4) {
      widget.onDone();
    } else {
      _x = 0;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.done) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '验证通过',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    // 未验证状态：显示可交互的滑块轨道
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Checkbox(
            value: widget.done,
            onChanged: null,
            side: const BorderSide(color: AppColors.outline),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: _onStart,
              onHorizontalDragUpdate: _onUpdate,
              onHorizontalDragEnd: _onEnd,
              child: SizedBox(
                height: _thumbSize,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.outline),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: _thumbSize,
                      width: _x + _thumbSize / 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    Positioned(
                      left: _x,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: _thumbSize,
                        height: _thumbSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.overlay,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        '拖动滑块验证',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeChatLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _WeChatLoginButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.wechat, size: 20, color: Color(0xFF07C160)),
        label: const Text('微信一键登录', style: AppTextStyles.labelLarge),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF07C160),
          side: const BorderSide(color: Color(0xFF07C160)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}
