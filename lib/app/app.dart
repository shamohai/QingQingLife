import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/deeplink/deep_link_receiver.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'theme/app_theme.dart';
import 'startup/startup_video_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        final router = ref.watch(appRouter);
        // 冷启动时微信授权回调完成的"需绑定手机号"分支：登录页已不在栈中，由这里跳转绑定页。
        // 登录页内的正常流程由 LoginPage 自行处理，这里只响应 initial 起始的状态变化。
        ref.listen<AuthStatus>(authProvider, (previous, next) {
          if (previous == AuthStatus.initial && next == AuthStatus.wechatAuthenticated) {
            router.push(RouteNames.phoneBind);
          }
        });

        return StartupVideoGate(
          child: DeepLinkReceiver(
            onLocation: router.go,
            child: MaterialApp.router(
              title: '青轻生活',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: AppTheme.themeData,
              darkTheme: AppTheme.darkThemeData,
              routerConfig: router,
              localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
              supportedLocales: const [Locale('zh', 'CN')],
              builder: (context, child) => child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
