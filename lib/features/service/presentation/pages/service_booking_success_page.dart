import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/service_booking_success_data.dart';

/// 服务预约、挚友会和活动报名共用的成功结果页。
///
/// 页面接收前置流程传入的上下文，不使用模拟业务数据。
class ServiceBookingSuccessPage extends StatelessWidget {
  final ServiceBookingSuccessData? data;

  const ServiceBookingSuccessPage({super.key, this.data});

  factory ServiceBookingSuccessPage.fromExtra(Object? extra) => ServiceBookingSuccessPage(data: extra is ServiceBookingSuccessData ? extra : null);

  @override
  Widget build(BuildContext context) {
    final isReservation = data?.source == ServiceBookingSuccessSource.reservation;
    final serviceTab = switch (data?.source) {
      ServiceBookingSuccessSource.reservation => 'fuwu',
      ServiceBookingSuccessSource.friendActivity => 'zhiyouhui',
      ServiceBookingSuccessSource.activity || null => 'huodong',
    };

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 480,
                      child: Image(image: AssetImage('assets/images/service/service_record_bg.png'), fit: BoxFit.cover),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 71, 16, 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 150,
                            height: 150,
                            child: Image(image: AssetImage('assets/images/points/icon-success.png'), fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '报名成功',
                            style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, height: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 43),
                          Text(
                            isReservation ? '你已成功提交预约，祝你活动愉快！' : '你已成功提交报名，祝你活动愉快！',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 68),
                          _SuccessActionRow(isReservation: isReservation, serviceTab: serviceTab),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SuccessActionRow extends StatelessWidget {
  final bool isReservation;
  final String serviceTab;

  const _SuccessActionRow({required this.isReservation, required this.serviceTab});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 308 ? 12.0 : 40.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SuccessActionButton(
              label: isReservation ? '更多预约' : '更多活动',
              onPressed: () => context.go(RouteNames.service, extra: {'initialTab': serviceTab}),
            ),
            SizedBox(width: gap),
            _SuccessActionButton(
              label: isReservation ? '预约记录' : '活动记录',
              onPressed: () =>
                  context.push(Uri(path: RouteNames.serviceRecords, queryParameters: {'activeTab': isReservation ? 'reservation' : 'activity'}).toString()),
            ),
          ],
        );
      },
    );
  }
}

class _SuccessActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SuccessActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 134,
      height: 39,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.primary, height: 1),
        ),
      ),
    );
  }
}
