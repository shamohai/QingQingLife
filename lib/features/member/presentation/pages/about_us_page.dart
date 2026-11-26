import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:qingqinglife/app/theme/app_spacing.dart';
import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_page_header.dart';

/// 关于我们页（/member/about-us）
///
/// 入口：「我的」页常用功能宫格「关于我们」（ProfileFeatureGrid）。
///
/// 结构（设计稿）：
///   浅灰渐变背景 → 返回栏「关于我们」→ 品牌 Logo（虚线框 + 竖排字 + 印章圆环）
///   → 版本号 → 链接卡片（检查更新 / 用户服务协议 / 用户隐私政策）→ 备案号
///   → 底部湖面插画（全宽、贴近屏幕底部，下方为留白）。
///
/// 说明：
///   - 版本号通过 package_info_plus 读取真实应用版本；
///     品牌 Logo 使用应用图标资源 assets/icon/logo.png（pubspec 已注册 assets/icon/）。
///   - 用户服务协议与隐私政策通过 App 内 H5 页面打开。
///   - 检查更新当前阶段统一提示「已是最新版本」，待版本检查接口接入后替换。
///   - 底部湖面插画取自设计稿切图 assets/images/member/about_lake_bg.png。
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (e) {
      AppLogger.warning('读取版本号失败', module: 'about_us', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 背景：浅灰渐变（底部渐白，承接插画下方留白）─────────────
            Positioned.fill(child: _buildBackground()),

            // ── 底部湖面插画（全宽，与屏幕底部留白同设计稿）─────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 51,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),

            // ── 前景内容 ───────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildNavBar(context),
                    const SizedBox(height: 42),
                    Image.asset('assets/icon/logo.png', width: 101.5, height: 101.5, fit: BoxFit.contain),
                    const SizedBox(height: 13.3),
                    Text(
                      '版本号 ${_version.isEmpty ? '—' : _version}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.2),
                    ),
                    const SizedBox(height: 40.1),
                    _buildLinkCard(context),
                    const SizedBox(height: 14.5),
                    const Text(
                      'APP备案服务号：青ICP备案0506767778号-41A',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 背景：顶浅灰 → 中段保持 → 底部渐白（湖面插画下方为白色留白）
  Widget _buildBackground() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.4, 0.65, 0.94],
          colors: [Color(0xFFF3F5F7), Color(0xFFF3F5F7), Color(0xFFF2F4F6), Color(0xFFFFFFFF)],
        ),
      ),
    );
  }

  /// 返回栏（黑字标题，页面为浅色底）
  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.pageTopGap),
      child: AppPageHeader(
        title: '关于我们',
        onBack: () => context.pop(),
        titleStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.2),
        iconColor: const Color(0xFF000000),
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
      ),
    );
  }

  /// 链接卡片：白色卡片（直角）+ 检查更新 / 用户服务协议 / 用户隐私政策
  Widget _buildLinkCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _LinkRow(label: '检查更新', height: 54.6, showDivider: true, onTap: _onCheckUpdate),
            _LinkRow(label: '用户服务协议', height: 57.5, showDivider: true, onTap: () => _openAgreement(context, RouteNames.userServiceAgreementUrl, '用户服务协议')),
            _LinkRow(label: '用户隐私政策', height: 57.5, showDivider: false, onTap: () => _openAgreement(context, RouteNames.userPrivacyPolicyUrl, '用户隐私政策')),
          ],
        ),
      ),
    );
  }

  /// 检查更新
  ///
  /// 阶段说明：版本发布流程尚未上线，点击后统一提示「当前已是最新版本」。
  /// 后续接入版本检查接口时，在此发起检查并复用 UpdateDialog 展示新版本。
  void _onCheckUpdate() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('当前已是最新版本'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _openAgreement(BuildContext context, String url, String title) async {
    final route = Uri(path: RouteNames.webView, queryParameters: {'url': url, 'title': title});
    await context.push(route.toString());
  }
}

/// 列表行：左标题 + 右箭头；分割线内缩（距卡片左右各 10）
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.height, required this.onTap, required this.showDivider});

  final String label;
  final double height;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.2),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, size: 28, color: Color(0xFF8E8E93)),
                  ],
                ),
              ),
            ),
            if (showDivider) Container(height: 0.83, margin: const EdgeInsets.symmetric(horizontal: 10), color: const Color(0xFFEEF2F6)),
          ],
        ),
      ),
    );
  }
}
