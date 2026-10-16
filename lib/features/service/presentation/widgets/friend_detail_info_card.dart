import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/models/service_project_detail_model.dart';

/// 挚友报名会详情内容卡片，独立于普通服务预约详情。
class FriendDetailInfoCard extends StatelessWidget {
  final ServiceProjectDetail project;

  const FriendDetailInfoCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        padding: const EdgeInsets.fromLTRB(19, 10, 19, 107),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 43,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 25,
                    child: Container(
                      width: 94,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.round),
                        gradient: const LinearGradient(colors: [AppColors.serviceProjectBlue, Color(0x00F3F5F7)]),
                      ),
                    ),
                  ),
                  const Text(
                    '活动简介',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              project.description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
