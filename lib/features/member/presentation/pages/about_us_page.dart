import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/router/route_names.dart';

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
///   - 版本号通过 package_info_plus 读取真实应用版本。
///   - 用户服务协议与隐私政策通过 App 内 H5 页面打开。
///   - 检查更新当前阶段统一提示「已是最新版本」，待版本检查接口接入后替换。
///   - TODO(资源): 品牌 Logo 为按设计稿还原的绘制实现、底部湖面插画取自设计稿切图
///     （项目暂无官方品牌切图资源），官方资源就绪后替换 _AboutLogoMark
///     与 assets/images/member/about_lake_bg.png 即可。
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
      debugPrint('[AboutUsPage] 读取版本号失败: $e');
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
                    const SizedBox(height: 56),
                    const _AboutLogoMark(),
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
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 9),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF000000)),
            ),
          ),
          const Text(
            '关于我们',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  /// 链接卡片：白色卡片（直角）+ 检查更新 / 用户服务协议 / 用户隐私政策
  Widget _buildLinkCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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

/// 品牌 Logo：米白底 + 虚线描边 + 竖排品牌名 + 印章圆环
///
/// TODO(资源): 官方 Logo 切图就绪后替换本组件内部实现。
class _AboutLogoMark extends StatelessWidget {
  const _AboutLogoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 101.5,
      height: 101.5,
      child: CustomPaint(
        // 虚线描边绘制在内容之上（foregroundPainter）
        foregroundPainter: const _DashedBorderPainter(color: Color(0xFF8C8C8C), dashLength: 2.6, gapLength: 1.6, strokeWidth: 1),
        child: DecoratedBox(
          decoration: BoxDecoration(color: const Color(0xFFFBFCF6), borderRadius: BorderRadius.circular(10.5)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: const _SealPainter())),
              Transform.translate(
                offset: const Offset(0, 2.2),
                child: const Text(
                  '青\n轻\n生\n活\n',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.5,
                    height: 0.82,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                    // 品牌字为宋体风格；按平台依次回退，缺失时退化为系统默认
                    fontFamily: 'Songti SC',
                    fontFamilyFallback: ['STSong', 'SimSun', '宋体', 'Noto Serif CJK SC', 'Noto Serif SC', 'serif'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 虚线矩形描边
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.dashLength, required this.gapLength, required this.strokeWidth});

  final Color color;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final source = Path()..addRect(rect);
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length).toDouble();
        dashed.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gapLength;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashLength != dashLength || oldDelegate.gapLength != gapLength || oldDelegate.strokeWidth != strokeWidth;
}

/// 印章纹样：上圆环（环绕上方品牌字，底部留口）+ 底部圆弧 + 四枚菱形星点
///
/// 设计稿实测：由两段圆环组成——
///   上环：圆心位于中心上方 31.0、半径 14.2，自 42.6° 逆时针扫 265.2°（底部留口）；
///   下弧：圆心位于中心下方 33.2、半径 14.7，自 159.7° 逆时针扫 139.4°；
/// 星点位于上下顶点与上环左右极点（整体构成仿印章的竖长构图）。
class _SealPainter extends CustomPainter {
  const _SealPainter();

  /// 印章色（设计稿：浅赭橙）
  static const Color _stampColor = Color(0xFFF4B485);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 轮廓：两段圆弧（描边极淡，还原设计稿的浅色效果）
    final stroke = Paint()
      ..color = _stampColor.withValues(alpha: 0.19)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.83;

    // 上环：底部留口的两百六十余度圆弧
    canvas.drawArc(Rect.fromCircle(center: center + const Offset(0, -31), radius: 14.2), 0.7435, -4.6286, false, stroke);

    // 下弧：底部短弧
    canvas.drawArc(Rect.fromCircle(center: center + const Offset(0, 33.2), radius: 14.7), 2.787, -2.433, false, stroke);

    final dotPaint = Paint()..color = _stampColor.withValues(alpha: 0.9);
    const dotOffsets = [Offset(0, -45.2), Offset(0, 47.9), Offset(-13.8, -30.9), Offset(13.8, -30.9)];
    for (final offset in dotOffsets) {
      canvas.save();
      canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 3.2, height: 3.2), dotPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}
