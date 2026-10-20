import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/providers/repository_providers.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/personal_info_form_card.dart';

/// 个人信息编辑页（/member/personal-info/edit）
///
/// 入口：「账号安全」页（/member/personal-info）底部「修改个人信息」按钮。
/// 保留旧版「个人信息」页实现：
///   顶部 bg-top350 插画背景（底部渐隐衔接淡蓝底）
///   → 透明返回栏「个人信息」→ 大头像（相机徽章）
///   → 表单卡片（昵称 / 性别 / 生日 / 修改资料）
/// 数据：昵称 / 头像取 userProfileProvider；资料保存通过 CompleteUserInfo 接口提交。
class PersonalInfoEditPage extends ConsumerStatefulWidget {
  const PersonalInfoEditPage({super.key});

  @override
  ConsumerState<PersonalInfoEditPage> createState() => _PersonalInfoEditPageState();
}

class _PersonalInfoEditPageState extends ConsumerState<PersonalInfoEditPage> {
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
        backgroundColor: const Color(0xFFDFEBFF),
        // fit: expand 让 Stack 撑满视口（Scaffold body 的约束是松散的，
        // 否则 Stack 会被内容撑出的高度决定，背景渐变无法铺满全屏）
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 背景：顶部插画 + 下方淡蓝渐变（不随内容滚动）──────────
            Positioned.fill(child: _buildBackground()),

            // ── 前景内容 ───────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom),
                child: Column(
                  children: [
                    _buildNavBar(context),
                    // 头像上沿与导航栏底部的距离（设计稿 158.7 - 状态栏 44 - 导航栏 30 ≈ 85）
                    const SizedBox(height: 85),
                    _buildHeader(profileState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 背景：顶部背景插画（全宽等比） + 底部渐隐 + 下方淡蓝渐变。
  ///
  /// TODO(资源): 设计稿卡片下方为湖面背景插画（暂无切图资源），
  /// 现以「#D4E2F7 → #DFEBFF」渐变近似，资源接入后替换。
  Widget _buildBackground() {
    return Column(
      // 撑满宽度：否则无子级的 DecoratedBox（下方渐变）在松散约束下会塌缩为 0 宽
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Image.asset('assets/images/member/bg-top350.png', width: double.infinity, fit: BoxFit.fitWidth),
            // 插画底部渐隐，与下方淡蓝背景无缝衔接
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 74,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00D4E2F7), Color(0xFFD4E2F7)]),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.45, 0.9],
                colors: [Color(0xFFD4E2F7), Color(0xFFD4E2F7), Color(0xFFDFEBFF)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 透明返回栏（叠在插画上，白字标题）
  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 12, right: 2),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
            ),
          ),
          const Text(
            '个人信息',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
          ),
        ],
      ),
    );
  }

  /// 头部区域：表单卡片 + 大头像（下沿压在卡片顶部之上）
  Widget _buildHeader(UserProfileState state) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 50.5, AppSpacing.md, 0),
          child: PersonalInfoFormCard(initialNickname: state.nickname, initialGender: state.gender, initialBirthday: state.birthday, onSave: _savePersonalInfo),
        ),
        _buildAvatar(state),
      ],
    );
  }

  /// 大头像（白描边）+ 右下角相机徽章
  Widget _buildAvatar(UserProfileState state) {
    final hasAvatar = state.avatarUrl != null && state.avatarUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: _onAvatarTap,
          child: Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFDDEAF6),
              child: hasAvatar
                  ? ClipOval(
                      child: AppNetworkImage(url: state.avatarUrl!, width: 80, height: 80, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_outline, size: 40, color: Color(0xFF8FA8BF)),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _onAvatarTap,
            child: Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF22418A), shape: BoxShape.circle),
                child: const Icon(Icons.photo_camera_outlined, size: 13, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onAvatarTap() {
    // TODO: 头像更换依赖图片上传接口，后端暂未提供，待接入后补充。
    debugPrint('[PersonalInfoEditPage] 头像/相机徽章点击');
  }

  Future<String?> _savePersonalInfo({required String nickname, required int gender, required DateTime birthday}) async {
    final response = await ref.read(memberRepositoryProvider).completeUserInfo(username: nickname, gender: gender, birthday: birthday);
    if (!response.success) {
      final message = response.message.trim();
      return message.isEmpty || message == 'unknown error' ? '资料保存失败，请稍后重试' : message;
    }

    await ref.read(userProfileProvider.notifier).load();
    if (mounted) context.pop();
    return null;
  }
}
