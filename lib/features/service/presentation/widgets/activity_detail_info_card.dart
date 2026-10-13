import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/models/service_project_detail_model.dart';

class ActivityDetailInfoCard extends StatelessWidget {
  final ServiceProjectDetail activity;

  const ActivityDetailInfoCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final contentImage = activity.detailImageAsset;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 19), child: _ActivityIntroHeader()),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _ActivityMetadata(activity: activity),
            ),
            if (contentImage != null) ...[
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: AspectRatio(
                  aspectRatio: 394 / 368,
                  child: Image.asset(contentImage, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityIntroHeader extends StatelessWidget {
  const _ActivityIntroHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class _ActivityMetadata extends StatelessWidget {
  final ServiceProjectDetail activity;

  const _ActivityMetadata({required this.activity});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataLine(label: '活动时间', value: activity.activityTime, style: style),
        _MetadataLine(label: '报名时间', value: activity.registrationTime, style: style),
        _MetadataLine(label: '活动地址', value: activity.activityAddress, style: style),
        _MetadataLine(label: '限制人数', value: activity.limitCount == null ? null : '${activity.limitCount}人', style: style),
      ],
    );
  }
}

class _MetadataLine extends StatelessWidget {
  final String label;
  final String? value;
  final TextStyle style;

  const _MetadataLine({required this.label, required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text('$label：$value', style: style),
    );
  }
}
