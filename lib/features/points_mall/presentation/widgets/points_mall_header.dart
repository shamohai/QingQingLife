import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../providers/points_mall_provider.dart';

/// 积分商城 Banner + 规则按钮
class PointsMallHeader extends ConsumerWidget {
  const PointsMallHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.read(pointsMallDataProvider);
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: AppNetworkImage(url: data.bannerUrl, width: double.infinity, height: 140, fit: BoxFit.cover),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRulesDialog(context, data.rulesText),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text('积分规则', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimaryContainer)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  void _showRulesDialog(BuildContext context, String rules) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('积分规则'),
        content: Text(rules, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }
}
