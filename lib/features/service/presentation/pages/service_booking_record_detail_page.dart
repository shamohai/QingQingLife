import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/models/offline_activity_detail_model.dart';
import '../../domain/models/reservation_service_detail_model.dart';
import '../providers/offline_activity_detail_provider.dart';
import '../providers/reservation_service_detail_provider.dart';

/// 服务预约/活动报名记录详情页面。
class ServiceBookingRecordDetailPage extends ConsumerWidget {
  final String id;
  final String type;

  const ServiceBookingRecordDetailPage({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReservation = type == 'reservation';
    final reservationId = int.tryParse(id);

    final Widget detailContent;
    if (isReservation) {
      if (reservationId == null || reservationId <= 0) {
        detailContent = const AppError(message: '预约服务编号无效');
      } else {
        final detailAsync = ref.watch(reservationBookingRecordDetailProvider(reservationId));
        detailContent = detailAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(reservationBookingRecordDetailProvider(reservationId))),
          data: (detail) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: _DetailCard.forReservation(detail: detail),
          ),
        );
      }
    } else if (id.isEmpty) {
      detailContent = const AppError(message: '活动编号无效');
    } else {
      final detailAsync = ref.watch(offlineActivityBookingRecordDetailProvider(id));
      detailContent = detailAsync.when(
        loading: () => const AppLoading(),
        error: (error, stackTrace) => AppError(message: '加载失败，请稍后重试', onRetry: () => ref.invalidate(offlineActivityBookingRecordDetailProvider(id))),
        data: (detail) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: _DetailCard.forActivity(detail: detail),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: Image(image: AssetImage('assets/images/service/service_record_bg.png'), fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _DetailHeader(),
                Expanded(child: detailContent),
              ],
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
  final ReservationServiceDetail? _reservationDetail;
  final OfflineActivityDetail? _activityDetail;

  const _DetailCard.forReservation({required ReservationServiceDetail detail}) : _reservationDetail = detail, _activityDetail = null;

  const _DetailCard.forActivity({required OfflineActivityDetail detail}) : _reservationDetail = null, _activityDetail = detail;

  @override
  Widget build(BuildContext context) {
    final reservation = _reservationDetail;
    final activity = _activityDetail;
    final title = reservation?.serviceName ?? activity!.title;
    final imageUrl = reservation?.headImgUrl ?? activity!.postUrl;
    final badge = reservation != null ? '服务预约' : '活动报名';
    final info = reservation?.myReservationInfo;
    final signupInfo = activity?.mySignupInfo;
    final signupId = signupInfo?.signupId ?? '';
    final identifier = signupId.isNotEmpty ? ('报名编号', signupId) : null;
    final rows = reservation != null ? _reservationRows(reservation, info) : _activityRows(activity!, signupInfo);
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
              SizedBox(width: 100, height: 100, child: AppNetworkImage(url: imageUrl, width: 100, height: 100, radius: 14)),
              const SizedBox(width: 5),
              Flexible(
                fit: FlexFit.loose,
                child: SizedBox(
                  height: 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 198),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              child: Text(
                                badge,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.serviceButtonRed, height: 1.5),
                              ),
                            ),
                            if (identifier != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${identifier.$1}：${identifier.$2}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93), height: 1.2),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE1E4E8)),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DetailRow(label: row.label, value: row.value),
            ),
          ),
        ],
      ),
    );
  }

  static List<({String label, String value})> _reservationRows(ReservationServiceDetail detail, Map<String, dynamic>? info) {
    final date = _readValue(info, 'reservationdate');
    final time = _readValue(info, 'reservationtime');
    final dateTime = [date, time].where((value) => value.isNotEmpty).join('  ');

    return [
      (label: '预约时间', value: dateTime),
      (label: '联系人', value: _readValue(info, 'contactname')),
      (label: '联系电话', value: _readValue(info, 'contactphonenumber')),
      if (detail.showIdNo) (label: '身份证号码', value: _readValue(info, 'idno')),
      (label: '预约人数', value: _readValue(info, 'usercount')),
      (label: '备注', value: _readValue(info, 'remark')),
    ];
  }

  static List<({String label, String value})> _activityRows(OfflineActivityDetail detail, MySignupInfo? signupInfo) {
    return [
      (label: '活动时间', value: detail.dateRangeDisplay),
      if (detail.addressList.isNotEmpty) (label: '活动地址', value: detail.addressList.first.address),
      (label: '联系人', value: signupInfo?.username ?? ''),
      (label: '联系电话', value: signupInfo?.phone ?? ''),
      (label: '身份证号码', value: signupInfo?.idNo ?? ''),
      (label: '报名人数', value: signupInfo?.signupUserCount.toString() ?? ''),
      (label: '备注', value: signupInfo?.remark ?? ''),
    ];
  }

  static String _readValue(Map<String, dynamic>? values, String key) {
    final value = values?[key];
    if (value is String) return value;
    return value?.toString() ?? '';
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
              value.isEmpty ? '' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: value.isEmpty ? const Color(0xFF8E8E93) : Colors.black, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
