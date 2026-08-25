import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// App 根 Widget，集成 Theme + Router + Riverpod
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouter);
        return MaterialApp.router(
          title: '青轻生活馆',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          routerConfig: router,
        );
      },
    );
  }
}