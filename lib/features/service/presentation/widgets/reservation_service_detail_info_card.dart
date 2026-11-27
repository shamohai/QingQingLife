import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/reservation_service_detail_model.dart';

/// 预约服务详情 — 白色圆角信息卡片（四角圆角，自适应高度）
///
/// 内部布局（Column 流式）：
///  - 标题 "项目简介"：24sp/Semibold，padding left=19 top=10
///  - 蓝色渐变分割线：94x7，borderRadius=999，margin top=18
///  - 描述正文：富文本（HtmlWidget），height 随内容自动适应
///
/// 卡片四角圆角（AppRadius.md），带轻微阴影。
class ReservationServiceDetailInfoCard extends StatelessWidget {
  final ReservationServiceDetail detail;

  const ReservationServiceDetailInfoCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                  Text(
                    '项目简介',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 描述正文：富文本 HTML，使用 HtmlWidget 渲染
            if (detail.descriptionHtml.isNotEmpty)
              HtmlWidget(
                _removeTableFixedHeights(detail.descriptionHtml),
                baseUrl: Uri.parse(AppConfig.baseUrl),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black, height: 1.5),
                // 兜底：通过 customStylesBuilder 再次确保单元格高度自适应
                customStylesBuilder: (element) {
                  final tag = element.localName;
                  if (tag == 'td' || tag == 'th') {
                    return {'height': 'auto', 'min-height': '0', 'vertical-align': 'top'};
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 预处理 HTML：移除 table/tr/td/th 的固定 height 样式
  /// 解决 flutter_widget_from_html 解析后仍施加固定高度约束导致溢出
  String _removeTableFixedHeights(String html) {
    return html
        // 移除 tr 的 height 样式
        .replaceAllMapped(RegExp(r'(<tr[^>]*\s)height\s*:\s*\d+px([^>]*>)'), (m) => '${m.group(1)}${m.group(2)}')
        .replaceAllMapped(RegExp(r'(<tr[^>]*\s)style\s*=\s*"([^"]*?)height\s*:\s*\d+px([^"]*?)"'), (m) {
          final style = m.group(2)!.replaceAll(RegExp(r'height\s*:\s*\d+px\s*;?'), '');
          return '${m.group(1)}style="$style"${m.group(3)}';
        })
        // 移除 td/th 的 height 样式
        .replaceAllMapped(RegExp(r'(<t[dh][^>]*\s)height\s*:\s*\d+px([^>]*>)'), (m) => '${m.group(1)}${m.group(2)}')
        .replaceAllMapped(RegExp(r'(<t[dh][^>]*\s)style\s*=\s*"([^"]*?)height\s*:\s*\d+px([^"]*?)"'), (m) {
          final style = m.group(2)!.replaceAll(RegExp(r'height\s*:\s*\d+px\s*;?'), '');
          return '${m.group(1)}style="$style"${m.group(3)}';
        });
  }
}
