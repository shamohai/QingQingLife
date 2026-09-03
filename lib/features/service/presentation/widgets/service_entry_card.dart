import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';

/// 服务列表单项卡片，用于 ServicePage（主入口）和 ServiceRecordsPage（记录列表）。
///
/// 左文右按钮布局，灰色胶囊按钮，点击后按 [listMode] 跳转对应路由。
class ServiceEntryCard extends StatelessWidget {
  final String title;
  final String buttonText;
  /// 对应的主 Tab key：'ongoing' | 'ended' | 'upcoming'
  final String listMode;

  const ServiceEntryCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.listMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  Uri(
                    path: RouteNames.serviceRecords,
                    queryParameters: {'activeTab': listMode},
                  ).toString(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4D4D4),
                foregroundColor: AppColors.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
