import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/app_loading.dart';
import '../pages/login_page.dart';
import '../providers/auth_provider.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final sessionState = ref.watch(sessionProvider);

    if (authStatus == AuthStatus.loading || sessionState == SessionState.loading) {
      return const Scaffold(body: AppLoading());
    }

    if (authStatus == AuthStatus.authenticated && sessionState == SessionState.authenticated) {
      // 登录成功，跳转到首页（由路由处理）
      context.go(RouteNames.home);
    }

    return const LoginPage();
  }
}