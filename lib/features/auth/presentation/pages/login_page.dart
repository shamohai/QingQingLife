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
  bool _agreed = false;

  void _onWechatAuth() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先阅读并同意用户协议'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(authProvider.notifier).wechatLogin();
  }



  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      if (previous == AuthStatus.loading && next == AuthStatus.wechatAuthenticated) {
        if (mounted) {
          context.push(RouteNames.phoneBind);
        }
      } else if (previous == AuthStatus.loading && next == AuthStatus.authenticated) {
        if (mounted) {
          context.go(RouteNames.profile);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            children: [
              // 返回按钮
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
                  onPressed: () => context.pop(),
                ),
              ),
              const Spacer(flex: 2),
              // Logo 区域
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceVariant,
                child: Icon(Icons.wechat, size: 40, color: Color(0xFF07C160)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'PIC',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onWechatAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    '微信一键授权',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 协议勾选
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
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
