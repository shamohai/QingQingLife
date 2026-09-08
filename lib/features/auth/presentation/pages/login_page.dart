import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _agreed = false;
  bool _showLoadingOverlay = false;

  void _onWechatAuth() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先阅读并同意用户协议'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _showLoadingOverlay = true);
    ref.read(authProvider.notifier).wechatLogin();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (previous == AuthStatus.loading && next == AuthStatus.wechatAuthenticated) {
        setState(() => _showLoadingOverlay = false);
        if (mounted) context.push(RouteNames.phoneBind);
      } else if (previous == AuthStatus.loading && next == AuthStatus.authenticated) {
        setState(() => _showLoadingOverlay = false);
        if (mounted) context.go(RouteNames.profile);
      } else if (next == AuthStatus.unauthenticated) {
        // 授权取消或失败：关闭遮罩，留在登录页
        setState(() => _showLoadingOverlay = false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Icon(Icons.wechat, size: 40, color: Color(0xFF07C160)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('PIC', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onWechatAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    ),
                    child: Text('微信一键授权', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      side: const BorderSide(color: AppColors.outline),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Text(
                          '登录即代表您已同意《用户服务协议》、《用户隐私政策》，未注册的手机号验证后将自动创建青轻生活馆账号。',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
          // 授权中遮罩：从点击按钮到回调返回全程覆盖，避免登录页裸露
          if (_showLoadingOverlay)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(child: AppLoading()),
            ),
        ],
      ),
    );
  }
}
