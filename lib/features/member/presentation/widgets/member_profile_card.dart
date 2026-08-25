import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/user_profile_provider.dart';

/// 顶部用户信息卡片
class MemberProfileCard extends ConsumerWidget {
  const MemberProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.read(userProfileProvider);
    final member = data.memberInfo;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A9C6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [const BoxShadow(color: Color(0x292E7D52), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.round),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          // 用户名 + 会员等级
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.nickname, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(member.levelName, style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          // 箭头
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}
