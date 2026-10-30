import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 服务预约/活动报名记录详情静态页面。
///
/// 当前使用蓝湖设计稿中的本地展示数据，不发起网络请求。
class ServiceBookingRecordDetailPage extends StatelessWidget {
  const ServiceBookingRecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 480,
            child: IgnorePointer(
              child: Image(image: AssetImage('assets/images/service/service_record_bg.png'), fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(children: [const _DetailHeader(), _DetailCard()]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: context.pop,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(width: 24, height: 24, child: Image(image: AssetImage('assets/images/service/icon_back_project_detail.png'))),
              ),
              const SizedBox(width: 6),
              Text(
                '记录详情',
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard();

  static const _rows = <({String label, String value})>[
    (label: '预约时间', value: '2026-10-01  12:30:09'),
    (label: '联系人', value: '吴彦祖'),
    (label: '联系电话', value: '13099878762'),
    (label: '身份证号码', value: '62242618767656'),
    (label: '报名人数', value: '2人'),
    (label: '备注', value: '很期待这次活动'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(13, 0, 13, 24),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 35),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  child: Image(image: AssetImage('assets/images/service/service_booking_golf_record.png'), fit: BoxFit.cover),
                ),
              ),
              const Spacer(),
              Flexible(
                fit: FlexFit.loose,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 198),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '高尔夫',
                          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 58,
                          height: 17,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.serviceButtonRed),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '服务预约',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.serviceButtonRed, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '预约编号：YYBH456789876789',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          const Divider(height: 1, color: Color(0xFFE1E4E8)),
          const SizedBox(height: 24),
          ..._rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DetailRow(label: row.label, value: row.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 21,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
