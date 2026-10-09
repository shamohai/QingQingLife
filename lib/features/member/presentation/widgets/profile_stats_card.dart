import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/user_profile_provider.dart';

/// 资产统计卡片（积分 / 卡券 / 天佑德值）
///
/// 三列等分 + 细分割线，底部为积分到期提醒条（条件渲染）。
class ProfileStatsCard extends ConsumerWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final hasExpiring = state.expiringPoints != null && state.expiringPoints! > 0 && state.expiringDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          // ── 三列统计 ──────────────────────────────────────────────
          Row(
            children: [
              _StatItem(number: '${state.points}', label: '积分'),
              const _StatDivider(),
              _StatItem(number: '${state.couponCount}', label: '卡券'),
              const _StatDivider(),
              _StatItem(number: '${state.tianyoudeValue}', label: '天佑德值', showInfoIcon: true),
            ],
          ),

          // ── 积分到期提醒 ──────────────────────────────────────────
          if (hasExpiring) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Image.asset('assets/images/points/icon-notification.png', width: 14, height: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '您有',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                      children: [
                        TextSpan(
                          text: '${state.expiringPoints}积分',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0088FF), fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '将于${state.expiringDate!.year}年${state.expiringDate!.month}月${state.expiringDate!.day}日到期',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final bool showInfoIcon;

  const _StatItem({required this.number, required this.label, this.showInfoIcon = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1D1C), height: 1.15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF666666)),
              ),
              if (showInfoIcon) ...[const SizedBox(width: 2), const Icon(Icons.info_outline, size: 13, color: Color(0xFF999999))],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFFEEEEEE));
  }
}
