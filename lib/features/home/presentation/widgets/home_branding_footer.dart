import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class HomeBrandingFooter extends StatelessWidget {
  const HomeBrandingFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('天佑德，天生与众不同', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w400, letterSpacing: 1)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}