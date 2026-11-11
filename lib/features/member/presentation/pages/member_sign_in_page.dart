import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/member_sign_in_models.dart';
import '../providers/member_sign_in_provider.dart';
import '../widgets/member_sign_in_calendar_grid.dart';
import '../widgets/member_sign_in_milestone_track.dart';
import '../widgets/member_sign_in_records.dart';

/// 会员签到页（/member/sign-in）
///
/// 结构（设计稿）：
///   浅蓝渐变背景：返回栏「会员签到」+ 我的积分 + 签到日历卡片
///   + 连续签到奖励 + 签到明细；右上角吉祥物叠在日历卡片之上；
///   底部固定签到栏（渐变按钮「立即签到」）。
/// 数据：由 [memberSignInProvider] 提供，数据源为 MemberDataSource；
/// 后端签到接口暂未接入时页面展示加载失败态。
class MemberSignInPage extends ConsumerStatefulWidget {
  const MemberSignInPage({super.key});

  @override
  ConsumerState<MemberSignInPage> createState() => _MemberSignInPageState();
}

class _MemberSignInPageState extends ConsumerState<MemberSignInPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memberSignInProvider.notifier).load();
    });
  }

  /// 签到：后端接口暂未接入时提示失败，接口就绪后按真实结果刷新页面
  Future<void> _handleSignIn() async {
    final result = await ref.read(memberSignInProvider.notifier).signIn();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result?.message ?? '签到失败，请稍后重试'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberSignInProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5E2F8),
        body: Stack(
          children: [
            const Positioned.fill(child: _SignInBackground()),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNav(context),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),

            // 吉祥物（设计稿：叠在日历卡片右上角之上，位于底部签到栏之下，不参与手势）
            if (state.overview != null)
              Positioned(
                top: topPadding + 36,
                right: 0,
                child: IgnorePointer(child: Image.asset('assets/images/member/member_sign_in_cow.png', width: 161)),
              ),

            // 底部固定签到栏（覆盖在滚动内容之上）
            Align(alignment: Alignment.bottomCenter, child: _buildBottomBar(state)),
          ],
        ),
      ),
    );
  }

  /// 顶部返回栏（标题左对齐）
  Widget _buildNav(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(7, 10, 2, 10),
              child: Icon(Icons.arrow_back_ios_new, size: 23, color: Color(0xFF1A2A47)),
            ),
          ),
          const Text(
            '会员签到',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A2A47)),
          ),
        ],
      ),
    );
  }

  /// 滚动内容：我的积分 + 三张卡片
  Widget _buildContent(MemberSignInState state) {
    final overview = state.overview;
    if (overview == null) {
      if (state.hasError) {
        return Center(
          child: AppError(message: state.errorMessage!, onRetry: () => ref.read(memberSignInProvider.notifier).load()),
        );
      }
      return const Center(child: AppLoading());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(memberSignInProvider.notifier).load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(overview),
            const SizedBox(height: 21),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: MemberSignInCalendarGrid(consecutiveDays: overview.consecutiveDays, days: overview.days),
            ),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: MemberSignInMilestoneTrack(milestones: overview.milestones),
            ),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: MemberSignInRecords(records: overview.records),
            ),
          ],
        ),
      ),
    );
  }

  /// 我的积分区（金币 + 文案 + 积分数字）
  Widget _buildHeader(MemberSignInOverview overview) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _PointsCoin(size: 20),
              SizedBox(width: 8),
              Text(
                '我的积分',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF33445F)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _formatPoints(overview.points),
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF0A1730), height: 1.2),
          ),
        ],
      ),
    );
  }

  /// 千分位格式化（如 143544 -> 143,544）
  static String _formatPoints(int value) => value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  /// 底部固定签到栏（顶部细分割线 + 渐变按钮）
  Widget _buildBottomBar(MemberSignInState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDFEBFF),
        border: Border(top: BorderSide(color: Color(0xFFC5D3E9), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 13, 26, 32),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: state.overview == null ? null : _handleSignIn,
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(21)),
                gradient: LinearGradient(colors: [Color(0xFF22418A), Color(0xFF2B52AE)]),
              ),
              child: const Text(
                '立即签到',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 页面背景：浅蓝竖向渐变 + 左上白色光晕 + 右上青色光晕（设计稿）
class _SignInBackground extends StatelessWidget {
  const _SignInBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.19, 0.38, 0.48],
          colors: [Color(0xFF80AAFE), Color(0xFFA8D0FB), Color(0xFFC5DCF9), Color(0xFFD5E2F8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -70, left: -50, child: _glow(260, const [Color(0x8CFFFFFF), Color(0x00FFFFFF)])),
          Positioned(top: -30, right: -70, child: _glow(300, const [Color(0xCC9EDDFC), Color(0x009EDDFC)])),
        ],
      ),
    );
  }

  Widget _glow(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

/// 积分金币（金色圆 + 深色描边 + 星形描边）
class _PointsCoin extends StatelessWidget {
  final double size;

  const _PointsCoin({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PointsCoinPainter());
  }
}

class _PointsCoinPainter extends CustomPainter {
  static const Color _lineColor = Color(0xFF3B4763);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // 金币底色：中心亮、边缘略深
    final fill = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        colors: [Color(0xFFE9DC55), Color(0xFFBFAE38)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 0.5, fill);

    // 外圈描边
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _lineColor;
    canvas.drawCircle(center, radius - 0.55, ring);

    // 星形描边（五角星，尖朝上）
    final star = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..color = _lineColor;
    canvas.drawPath(_starPath(center, radius * 0.52, radius * 0.24), star);
  }

  Path _starPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PointsCoinPainter oldDelegate) => false;
}
