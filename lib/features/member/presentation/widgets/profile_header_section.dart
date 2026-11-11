import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/auth_redirect.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/providers/session_provider.dart';
import '../providers/user_profile_provider.dart';
import 'user_avatar_image.dart';

/// 用户信息头部区域（透明背景，由页面顶部渐变背景承载）
///
/// 布局：头像（左）+ 昵称/手机号（中）+ 客服 / 消息图标（右）
class ProfileHeaderSection extends ConsumerWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final isAuthenticated = ref.watch(sessionProvider) == SessionState.authenticated;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.sm, bottom: AppSpacing.md),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            // ── 用户信息区（头像 / 昵称 / 手机号，点击进入「个人信息」页）──
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isAuthenticated) {
                    context.push(RouteNames.personalInfo);
                  } else {
                    context.push(loginLocationFor(RouteNames.profile));
                  }
                },
                child: Row(
                  children: [
                    // ── 头像（白色描边圆）──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFDDEAF6),
                        child: ClipOval(
                          child: UserAvatarImage(avatarUrl: state.avatarUrl, previewBytes: state.avatarPreviewBytes, size: 56, iconSize: 30),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // ── 昵称 / 手机号 ──────────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isAuthenticated ? state.nickname : '点击登录',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1D1C), height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isAuthenticated ? state.phoneMasked : '登录后享会员权益',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF4A5568)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 客服入口 ──────────────────────────────────────────────
            const SizedBox(width: AppSpacing.sm),

            // ── 消息入口（未读数 > 0 时显示红色角标）──────────────────
            _HeaderIconButton(icon: Icons.chat_bubble_outline, badgeCount: state.unreadMessageCount, onTap: () => context.push(RouteNames.notifications)),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 26, color: const Color(0xFF1A1D1C))),
            if (badgeCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(color: const Color(0xFFFF4D4F), borderRadius: BorderRadius.circular(9)),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
