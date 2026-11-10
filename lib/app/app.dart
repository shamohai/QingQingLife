import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/deeplink/deep_link_receiver.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        final router = ref.watch(appRouter);

        return DeepLinkReceiver(
          onLocation: router.go,
          child: MaterialApp.router(
            title: '青轻生活',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.themeData,
            darkTheme: AppTheme.darkThemeData,
            routerConfig: router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('zh', 'CN')],
            builder: (context, child) => child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
