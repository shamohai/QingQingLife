import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/umeng_analytics.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/deeplink/deep_link_receiver.dart';
import '../core/network/providers.dart';
import '../core/update/models/app_update_info.dart';
import '../core/update/providers/app_update_provider.dart';
import '../core/update/services/startup_video_update_service_stub.dart' if (dart.library.io) '../core/update/services/startup_video_update_service.dart';
import '../core/update/widgets/app_update_dialog.dart';
import 'startup/startup_video_gate.dart';

/// 全局资源 bundle：热更新镜像中有同名文件则优先使用
final _hotAssetBundle = HotAssetBundle();

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  /// 等待弹出的 apk 升级信息（启动视频播放期间拿到的结果会先暂存）
  AppUpdateInfo? _pendingUpdate;

  /// 启动视频是否已结束，MaterialApp 已挂载
  bool _appReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(umengAnalyticsProvider).onAppLifecycleChanged(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouter);

    // 仅 apk 升级会返回结果；纯热更新在 appUpdateProvider 中已被过滤，不弹窗
    ref.listen(appUpdateProvider, (previous, next) {
      final info = next.value;
      if (info == null) return;
      _pendingUpdate = info;
      _tryShowUpdateDialog();
    });

    return StartupVideoGate(
      onReady: () {
        _appReady = true;
        _tryShowUpdateDialog();
      },
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
          builder: (context, child) => DefaultAssetBundle(bundle: _hotAssetBundle, child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }

  /// 条件满足（启动视频结束 + 有待弹信息）时弹出升级窗口，弹出后清空待弹状态
  void _tryShowUpdateDialog() {
    final info = _pendingUpdate;
    if (!_appReady || info == null) return;
    _pendingUpdate = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) {
        // 导航尚未就绪，放回待弹状态，等下一次触发
        _pendingUpdate = info;
        return;
      }
      showAppUpdateDialog(ctx, info, onDismissToday: () => ref.read(localStorageProvider).putString(appUpdateDismissedDateKey, todayDateKey()));
    });
  }
}
