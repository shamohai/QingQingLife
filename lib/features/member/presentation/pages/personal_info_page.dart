import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/account_security_card.dart';
import '../widgets/user_avatar_image.dart';

/// 账号安全页（/member/personal-info）
///
/// 入口：「我的」页头像 / 昵称区域点击（ProfileHeaderSection）、功能宫格「个人信息」。
/// 结构（设计稿）：
///   顶部 bg-top350 插画背景（底部渐隐衔接页面淡蓝底色）
///   → 透明返回栏「账号安全」→ 大头像
///   → 账号信息卡片（UID / 昵称 / 性别 / 出生日期 / 手机号 / 版本号 / 我的地址）
///   → 底部固定操作栏（修改个人信息）
/// 「修改个人信息」跳转旧版表单页（/member/personal-info/edit）。
/// 数据：账号信息取 userProfileProvider / memberAddressesProvider；
/// 注销账号入口按需求隐藏；修改绑定手机号接口后端暂未提供，相关交互标记 TODO。
class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  /// 底部操作栏内容高度（上 11 + 按钮 44 + 下 23，不含系统安全区）
  static const double _barHeight = 78;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFD4E2F7),
        // fit: expand 让 Stack 撑满视口（Scaffold body 的约束是松散的，
        // 否则 Stack 会被内容撑出的高度决定，背景无法铺满全屏）
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 顶部插画背景（底部渐隐，不随内容滚动）─────────────────
            Positioned(top: 0, left: 0, right: 0, child: _buildBanner()),

            // ── 前景内容 ───────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: _barHeight + MediaQuery.paddingOf(context).bottom + AppSpacing.lg),
                child: Column(
                  children: [
                    _buildNavBar(context),
                    // 标题栏统一为 44 高，收回差值以保持头像在设计稿中的位置。
                    const SizedBox(height: 74.7),
                    _buildHeader(profileState),
                  ],
                ),
              ),
            ),

            // ── 底部操作栏（固定，不随内容滚动）────────────────────────
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar(context)),
          ],
        ),
      ),
    );
  }

  /// 顶部插画背景（全宽等比） + 底部渐隐（衔接页面底色 #D4E2F7）
  Widget _buildBanner() {
    return Stack(
      children: [
        Image.asset('assets/images/member/bg-top350.png', width: double.infinity, fit: BoxFit.fitWidth),
        // 插画底部渐隐，与页面底色无缝衔接（设计稿渐隐区约 85）
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 85,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00D4E2F7), Color(0xFFD4E2F7)]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 透明返回栏（叠在插画上，白字标题）
  Widget _buildNavBar(BuildContext context) {
    return AppPageHeader(
      title: '个人信息',
      onBack: () => context.pop(),
      titleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
      iconColor: Colors.white,
    );
  }

  /// 头部区域：账号信息卡片 + 大头像（头像上沿高出卡片，下沿压入卡片）
  Widget _buildHeader(UserProfileState state) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const Padding(
          // 卡片上沿与头像上沿的距离（设计稿：头像顶 162.7 → 卡片顶 212.5）
          padding: EdgeInsets.fromLTRB(14, 49.8, 14, 0),
          child: AccountSecurityCard(),
        ),
        _buildAvatar(state),
      ],
    );
  }

  /// 大头像（设计稿无描边/徽章，直径 57px ≈ 80.7；无头像地址时展示占位人形图标）
  Widget _buildAvatar(UserProfileState state) {
    return CircleAvatar(
      radius: 40.35,
      backgroundColor: const Color(0xFFDDEAF6),
      child: ClipOval(
        child: UserAvatarImage(avatarUrl: state.avatarUrl, previewBytes: state.avatarPreviewBytes, size: 80.7, iconSize: 38),
      ),
    );
  }

  /// 底部操作栏：修改个人信息（渐变）
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDFEBFF),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, -1))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 23),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: SizedBox(width: double.infinity, child: _buildEditInfoButton(context)),
            ),
          ),
        ),
      ),
    );
  }

  /// 「修改个人信息」→ 旧版表单页（/member/personal-info/edit）
  Widget _buildEditInfoButton(BuildContext context) {
    return GestureDetector(
      key: const Key('personal_info_edit_button'),
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(RouteNames.personalInfoEdit),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF22418A), Color(0xFF2F57BA)]),
        ),
        child: const Text(
          '修改个人信息',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
        ),
      ),
    );
  }
}
