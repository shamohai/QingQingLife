import 'package:flutter/material.dart';

import '../../domain/models/notification_models.dart';

/// 通知详情弹窗
///
/// 展示 getmynotificationlist 返回的全部字段：类型名称、标题、发送时间、正文内容。
class NotificationDetailDialog extends StatelessWidget {
  final NotificationMessage message;

  /// 类型名称（来源于类型统计接口的 typename）
  final String typeName;

  const NotificationDetailDialog({super.key, required this.message, required this.typeName});

  /// 以弹窗形式打开通知详情
  static Future<void> show(BuildContext context, {required NotificationMessage message, required String typeName}) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x52000000),
      builder: (_) => NotificationDetailDialog(message: message, typeName: typeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFDFEBFF),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        // 长内容可滚动，避免超出屏幕
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF16233C), height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      _buildMetaRow(),
                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFFD6E3FA)),
                      const SizedBox(height: 12),
                      Text(
                        message.content,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF33415A), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '关闭',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF24427A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 弹窗标题栏：类型名称（左）+ 关闭按钮（右，严格贴右侧内边距）
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            typeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF24427A)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close, size: 20, color: Color(0xFF5C79B4)),
        ),
      ],
    );
  }

  /// 发送时间
  Widget _buildMetaRow() {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 14, color: Color(0xFF5C79B4)),
        const SizedBox(width: 4),
        Text(
          message.createTime,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF5C79B4)),
        ),
      ],
    );
  }
}
