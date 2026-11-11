import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../app/config/app_config.dart';
import '../../domain/models/offline_activity_detail_model.dart';

class ActivityDetailInfoCard extends StatelessWidget {
  final OfflineActivityDetail detail;

  const ActivityDetailInfoCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
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
              child: _ActivityMetadata(detail: detail),
            ),
            if (detail.contentHtml.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: HtmlWidget(
                  detail.contentHtml,
                  baseUrl: Uri.parse(AppConfig.baseUrl),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                ),
              ),
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
  final OfflineActivityDetail detail;

  const _ActivityMetadata({required this.detail});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataLine(label: '活动时间', value: detail.dateRangeDisplay, style: style),
        // 报名时间字段暂无，后端补充后可添加
        if (detail.addressList.isNotEmpty)
          ...detail.addressList.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final address = entry.value;
            final label = detail.addressList.length > 1 ? '活动地址$index' : '活动地址';
            // 调试：打印地址对象

            return _MetadataLine(label: label, value: address.address, style: style);
          }),
        _MetadataLine(label: '限制人数', value: detail.maxSignupCount > 0 ? '${detail.maxSignupCount}人' : null, style: style),
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
