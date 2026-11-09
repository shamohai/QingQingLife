import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../domain/models/notification_models.dart';

/// 通知消息卡片
///
/// 结构：头部（类型图标 + 类型名称 + 发送时间）/ 分割线 / 标题（未读红点）/ 正文 / 分割线 / 查看详情。
/// 类型名称与图标均来源于类型统计接口（typename / icon）；图标缺失时用通用通知图标占位。
/// 点击整卡或「查看详情」均打开详情弹窗。
class NotificationMessageCard extends StatelessWidget {
  final NotificationMessage message;

  /// 类型名称（来源于类型统计接口的 typename）
  final String typeName;

  /// 类型图标地址（来源于类型统计接口的 icon，可能为空）
  final String iconUrl;

  final VoidCallback? onDetailTap;

  const NotificationMessageCard({super.key, required this.message, required this.typeName, this.iconUrl = '', this.onDetailTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFDFEBFF), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeIcon(),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    typeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF33415A)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  message.createTime,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF5C79B4)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _Hairline(),
            const SizedBox(height: 11),
            Row(
              children: [
                if (message.isUnread) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFFE02E2A), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    message.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF16233C), height: 1.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              message.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E9BB3), height: 1.35),
            ),
            const SizedBox(height: 8),
            const _Hairline(),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text(
                  '查看详情',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF33415A)),
                ),
                Spacer(),
                Icon(Icons.chevron_right, size: 18, color: Color(0xFF36445C)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 类型图标：22 圆形底 + 接口 icon；缺失或加载失败时用通用通知图标占位
  Widget _buildTypeIcon() {
    if (iconUrl.trim().isEmpty) return _buildPlaceholderIcon();

    return ClipOval(
      child: AppNetworkImage(url: iconUrl, width: 22, height: 22, fit: BoxFit.cover, errorWidget: _buildPlaceholderIcon()),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(color: Color(0xFF24427A), shape: BoxShape.circle),
      child: const Icon(Icons.notifications_rounded, size: 13, color: Colors.white),
    );
  }
}

/// 卡片内分割线
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFD6E3FA));
  }
}
