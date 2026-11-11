import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_spacing.dart';

import 'package:qingqinglife/core/logging/app_logger.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/personal_info_form_card.dart';
import '../widgets/user_avatar_image.dart';

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
  bool _isUploadingAvatar = false;

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
              child: ClipOval(
                child: UserAvatarImage(avatarUrl: state.avatarUrl, previewBytes: state.avatarPreviewBytes, size: 80, iconSize: 40),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _isUploadingAvatar ? null : _onAvatarTap,
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
        if (_isUploadingAvatar)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _onAvatarTap() async {
    if (_isUploadingAvatar) return;

    final source = await AppBottomSheet.show<_AvatarSource>(
      context: context,
      title: '更换头像',
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
      child: const _AvatarSourcePicker(),
    );
    if (!mounted || source == null) return;

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source == _AvatarSource.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        requestFullMetadata: false,
      );
    } on PlatformException catch (error) {
      if (mounted) _showAvatarError(_avatarPickerErrorMessage(error.code));
      return;
    } catch (error) {
      AppLogger.error('pick avatar error', module: 'personal_info_edit', error: error);
      if (mounted) _showAvatarError('无法打开相机或相册，请稍后重试');
      return;
    }

    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.isEmpty) {
      _showAvatarError('读取图片失败，请重新选择');
      return;
    }

    setState(() => _isUploadingAvatar = true);
    final errorMessage = await ref.read(userProfileProvider.notifier).changeAvatar(bytes: bytes, ext: _avatarExtension(picked.name, bytes));
    if (!mounted) return;

    setState(() => _isUploadingAvatar = false);
    if (errorMessage != null) {
      _showAvatarError(errorMessage);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('头像已更新'), behavior: SnackBarBehavior.floating));
  }

  String _avatarPickerErrorMessage(String code) {
    return switch (code) {
      'camera_access_denied' => '未获得相机权限，请在系统设置中允许访问相机',
      'photo_access_denied' => '未获得相册权限，请在系统设置中允许访问照片',
      _ => '无法打开相机或相册，请稍后重试',
    };
  }

  void _showAvatarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  String _avatarExtension(String fileName, Uint8List bytes) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex >= 0 && dotIndex < fileName.length - 1) {
      final extension = fileName.substring(dotIndex + 1).toLowerCase();
      return extension == 'jpeg' ? 'jpg' : extension;
    }

    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'jpg';
    if (bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'png';
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }
    return 'jpg';
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

enum _AvatarSource { camera, gallery }

class _AvatarSourcePicker extends StatelessWidget {
  const _AvatarSourcePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AvatarSourceRow(icon: Icons.photo_camera_outlined, label: '拍照', onTap: () => Navigator.of(context).pop(_AvatarSource.camera)),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        _AvatarSourceRow(icon: Icons.photo_library_outlined, label: '相册', onTap: () => Navigator.of(context).pop(_AvatarSource.gallery)),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        _AvatarSourceRow(icon: Icons.close, label: '取消', onTap: () => Navigator.of(context).pop()),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AvatarSourceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AvatarSourceRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Center(
          child: SizedBox(
            width: 120,
            child: Row(
              children: [
                SizedBox(width: 24, child: Icon(icon, size: 21, color: const Color(0xFF22418A))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1D1C)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
