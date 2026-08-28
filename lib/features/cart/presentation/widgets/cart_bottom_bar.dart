import 'package:flutter/material.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../providers/cart_provider.dart';

class CartBottomBar extends ConsumerWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartDataProvider);
    final selectedTotal = Money.fromCents(state.selectedTotalCents);
    final allSelected = state.allSelected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Checkbox(
                value: allSelected,
                onChanged: (v) => ref.read(cartDataProvider.notifier).toggleAll(v),
                activeColor: AppColors.primary,
              ),
              Text('全选', style: AppTextStyles.bodyMedium),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('合计', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              Text(
                selectedTotal.format(),
                style: AppTextStyles.priceLarge.copyWith(color: AppColors.error),
              ),
              if (state.items.isNotEmpty && !allSelected)
                Text(
                  '已优惠：30.00',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 88,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: const Center(
              child: Text('去结算', style: AppTextStyles.labelMedium),
            ),
          ),
        ],
      ),
    );
  }
}
