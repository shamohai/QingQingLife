import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../domain/repositories/member_repository.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/user_profile_provider.dart';
import '../../../../core/widgets/app_image.dart';

class UserInfoCard extends ConsumerWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final member = state.memberInfo;
    final avatarUrl = state.avatarUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.login),
        child: Row(
          children: [
            _AvatarWidget(url: avatarUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.phoneMasked, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 6),
                  _MemberChip(member: member),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _pillBtn(context, '客服', onTap: () {}),
                const SizedBox(height: 6),
                _pillBtn(context, '设置', isOutline: true, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillBtn(BuildContext ctx, String label, {bool isOutline = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : const Color(0xFFF5F5F5),
          border: isOutline ? Border.all(color: AppColors.outline) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String? url;
  const _AvatarWidget({this.url});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [const BoxShadow(color: Color(0x1A2E7D52), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: url != null ? AppNetworkImage(url: url!, fit: BoxFit.cover, radius: 28) : const Icon(Icons.person, size: 30, color: AppColors.primary),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final MemberInfo member;
  const _MemberChip({required this.member});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
          child: Text(
            member.levelName,
            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 4),
        Text('天佑德值', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
