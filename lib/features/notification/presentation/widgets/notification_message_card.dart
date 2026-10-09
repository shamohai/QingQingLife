import 'package:flutter/material.dart';

import '../../domain/repositories/notification_repository.dart';

/// 通知消息卡片
///
/// 结构：头部（来源图标 + 来源标签 + 时间）/ 分割线 / 标题（未读红点）/ 正文 / 分割线 / 查看详情。
class NotificationMessageCard extends StatelessWidget {
  final NotificationMessage message;
  final VoidCallback? onDetailTap;

  const NotificationMessageCard({super.key, required this.message, this.onDetailTap});

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
                _buildSourceIcon(),
                const SizedBox(width: 6),
                Text(
                  message.source.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF33415A)),
                ),
                const Spacer(),
                Text(
                  message.formattedTime,
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E9BB3), height: 1.35),
            ),
            const SizedBox(height: 8),
            const _Hairline(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '查看详情',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF33415A)),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF36445C)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 来源图标：22 圆形底色 + 白色图标
  Widget _buildSourceIcon() {
    final (IconData icon, Color background) = switch (message.source) {
      NotificationSource.announcement => (Icons.campaign_rounded, const Color(0xFF22418A)),
      NotificationSource.systemNotice => (Icons.notifications_rounded, const Color(0xFFE69746)),
      NotificationSource.orderNotice => (Icons.receipt_long_rounded, const Color(0xFFE69746)),
      NotificationSource.serviceNotice => (Icons.card_giftcard_rounded, const Color(0xFFE2544A)),
    };
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 13, color: Colors.white),
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
