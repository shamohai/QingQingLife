import 'package:flutter/material.dart';

/// 服务券点击后的底部操作菜单。
///
/// 返回值是用户选择的操作文案；点击关闭按钮返回 null。
class ServiceCouponActionSheet extends StatelessWidget {
  final String couponName;
  final bool canDeliver;
  final bool canTransfer;
  final List<String>? actionLabels;

  const ServiceCouponActionSheet({super.key, required this.couponName, required this.canDeliver, required this.canTransfer, this.actionLabels});

  List<String> get actions => actionLabels ?? ['到店使用', if (canDeliver) '快递到家', if (canTransfer) '转增好友'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 64,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Text(
                        couponName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 26, color: Color(0xFF1A1D1C)),
                    ),
                  ),
                ],
              ),
            ),
            for (final action in actions) _ActionRow(label: action),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;

  const _ActionRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(label),
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1D1C), height: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
