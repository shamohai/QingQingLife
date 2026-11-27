import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/offline_activity_detail_model.dart';

/// 挚友报名会详情内容卡片，独立于普通服务预约详情。
///
/// 渲染 [detail] 的 contenthtml 富文本。
class FriendDetailInfoCard extends StatelessWidget {
  final OfflineActivityDetail? detail;

  const FriendDetailInfoCard({super.key, this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            if (detail != null && detail!.contentHtml.isNotEmpty)
              HtmlWidget(
                _removeTableFixedHeights(detail!.contentHtml),
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
