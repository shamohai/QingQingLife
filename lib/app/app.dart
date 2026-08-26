import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/update/providers/version_check_provider.dart';
import '../core/update/widgets/update_dialog.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        final router = ref.watch(appRouter);
        final versionCheckState = ref.watch(versionCheckProvider);

        return MaterialApp.router(
          title: '青轻生活馆',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.themeData,
          darkTheme: AppTheme.darkThemeData,
          routerConfig: router,
          builder: (context, child) {
            if (versionCheckState.state == VersionCheckState.checked &&
                versionCheckState.info != null &&
                versionCheckState.info!.shouldShowDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                final info = versionCheckState.info!;
                showDialog(
                  context: context,
                  barrierDismissible: !info.isForceUpdate,
                  builder: (dialogContext) => UpdateDialog(
                    info: info,
                    onConfirm: () {
                      // TODO: 触发实际更新逻辑
                    },
                  ),
                );
              });
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
