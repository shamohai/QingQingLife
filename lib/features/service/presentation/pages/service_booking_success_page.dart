import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/service_booking_success_data.dart';

/// 服务预约、挚友会和活动报名共用的成功结果页。
///
/// 页面只展示前置流程传入的本地结果上下文，不发起网络请求。
class ServiceBookingSuccessPage extends StatelessWidget {
  final ServiceBookingSuccessData data;

  const ServiceBookingSuccessPage({super.key, required this.data});

  factory ServiceBookingSuccessPage.fromExtra(dynamic extra) {
    if (extra is ServiceBookingSuccessData) {
      return ServiceBookingSuccessPage(data: extra);
    }
    return const ServiceBookingSuccessPage(data: ServiceBookingSuccessData.activityMock());
  }

  @override
  Widget build(BuildContext context) {
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
                          const Text(
                            '你已成功提交报名，祝你活动愉快！',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 68),
                          _SuccessActionRow(data: data),
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
  final ServiceBookingSuccessData data;

  const _SuccessActionRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 308 ? 12.0 : 40.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SuccessActionButton(label: '返回首页', onPressed: () => context.go(RouteNames.home)),
            SizedBox(width: gap),
            _SuccessActionButton(
              label: '预约记录',
              onPressed: () {
                final uri = Uri(path: RouteNames.serviceRecords, queryParameters: {'activeTab': data.recordTab});
                context.push(uri.toString());
              },
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
