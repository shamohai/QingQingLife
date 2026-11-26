import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../logging/app_logger.dart';
import '../storage/privacy_consent_storage.dart';

/// 友盟统计服务。
///
/// 合规要求：只有用户在登录页同意《用户隐私政策》后，才调用正式初始化函数。
/// 未同意的用户（包括游客）不初始化、不采集、不上报。
/// Android 与 iOS 使用各自在友盟后台创建的 AppKey。
class UmengAnalytics {
  UmengAnalytics({PrivacyConsentStorage? consentStorage}) : _consentStorage = consentStorage ?? PrivacyConsentStorage();

  // 与 MyApplication.kt 中 preInit 使用的 AppKey 保持一致。
  static const _androidAppKey = '6af189d16545637cd6451016';
  static const _iosAppKey = '6af18a53863270068cbda647';
  static const _channel = 'Umeng';

  final PrivacyConsentStorage _consentStorage;
  // 静态标记：同一进程内无论创建多少实例，正式初始化只执行一次。
  static bool _initialized = false;
  static bool _appResumed = true;
  static bool _pageStarted = false;
  static String? _currentPageName;
  static String? _currentPageKey;

  static bool get _isSupportedPlatform => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// 用户同意隐私政策后调用：记录同意状态并完成友盟正式初始化。
  Future<void> onPrivacyAccepted() async {
    await _consentStorage.setAccepted(true);
    await _initialize();
  }

  /// App 冷启动时调用：仅当用户此前已同意时才初始化，否则什么也不做。
  Future<void> initIfConsented() async {
    if (!await _consentStorage.isAccepted()) return;
    await _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized || !_isSupportedPlatform) return;
    try {
      await UmengCommonSdk.initCommon(_androidAppKey, _iosAppKey, _channel);
      UmengCommonSdk.setPageCollectionModeManual();
      _initialized = true;
      _startCurrentPage();
    } catch (error, stackTrace) {
      // 统计失败不影响业务流程。
      AppLogger.warning('友盟初始化失败', module: 'umeng_analytics', error: error, stackTrace: stackTrace);
    }
  }

  /// 由 GoRouter 全局路由监听调用；页面名使用路由模板，不包含实际参数。
  void trackPage({required String pageName, required String pageKey}) {
    if (pageName.isEmpty || (pageName == _currentPageName && pageKey == _currentPageKey)) return;

    _endCurrentPage();
    _currentPageName = pageName;
    _currentPageKey = pageKey;
    _startCurrentPage();
  }

  /// 页面进入后台时结束当前页，回到前台后重新开始统计。
  void onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_appResumed) return;
      _appResumed = true;
      _startCurrentPage();
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (!_appResumed) return;
      _appResumed = false;
      _endCurrentPage();
    }
  }

  static void _startCurrentPage() {
    final pageName = _currentPageName;
    if (!_initialized || !_isSupportedPlatform || !_appResumed || _pageStarted || pageName == null) return;

    UmengCommonSdk.onPageStart(pageName);
    _pageStarted = true;
  }

  static void _endCurrentPage() {
    final pageName = _currentPageName;
    if (!_initialized || !_isSupportedPlatform || !_pageStarted || pageName == null) return;

    UmengCommonSdk.onPageEnd(pageName);
    _pageStarted = false;
  }
}

final umengAnalyticsProvider = Provider<UmengAnalytics>((ref) => UmengAnalytics());
