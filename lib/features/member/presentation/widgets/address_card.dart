import 'package:flutter/material.dart';

import '../../domain/repositories/member_repository.dart';

/// 收货地址卡片（「收货地址」列表页）
///
/// 展示：姓名 + 手机号 / 省市区 / 详细地址 / 编辑入口 / 默认地址选择 / 删除入口。
/// 默认（选中）状态：1.5px 蓝色描边 + 蓝色勾选圆点；未选中：灰色圆环。
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.onSetDefault, this.onEdit, this.onDelete});

  final MemberAddress address;

  /// 设为默认地址（当前已是默认地址时传 null）
  final VoidCallback? onSetDefault;

  /// 编辑地址
  final VoidCallback? onEdit;

  /// 删除地址
  final VoidCallback? onDelete;

  /// 卡片高度（设计稿 139）
  static const double height = 139;

  static const Color _defaultColor = Color(0xFF0088FF);
  static const Color _nameColor = Color(0xFF223875);
  static const Color _grayColor = Color(0xFF8E8E93);
  static const Color _labelColor = Color(0xFF171717);
  static const Color _dividerColor = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      // 选中态描边画在前景：与设计稿一致，两种状态内容布局完全相同（描边不挤压内容）
      foregroundDecoration: address.isDefault
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _defaultColor, width: 1.5),
            )
          : null,
      child: Stack(
        children: [
          // 姓名 + 手机号
          Positioned(
            left: 8.5,
            top: 10.9,
            child: Row(
              children: [
                Text(
                  address.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _nameColor, height: 1.2),
                ),
                const SizedBox(width: 6),
                Text(address.phone, style: const TextStyle(fontSize: 18.5, color: _nameColor, height: 1.2)),
              ],
            ),
          ),
          // 省市区
          Positioned(
            left: 8.5,
            top: 51.8,
            child: Text('${address.province} ${address.city} ${address.district}', style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.2)),
          ),
          // 详细地址
          Positioned(
            left: 8.5,
            top: 71.8,
            child: Text(address.detail, style: const TextStyle(fontSize: 13.5, color: Colors.black, height: 1.2)),
          ),
          // 编辑
          Positioned(
            right: 8.4,
            top: 39,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.edit_square, size: 16.5, color: _grayColor),
              ),
            ),
          ),
          // 分割线
          const Positioned(
            left: 8.5,
            right: 8.9,
            top: 97.75,
            child: SizedBox(height: 1, child: ColoredBox(color: _dividerColor)),
          ),
          // 底部行：默认地址 + 删除
          Positioned(
            left: 8,
            right: 18.5,
            top: 98.75,
            height: 33,
            child: Row(
              children: [
                // 默认地址（设为默认）
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSetDefault,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDefaultIndicator(),
                      const SizedBox(width: 6.1),
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('默认地址', style: TextStyle(fontSize: 14, color: _labelColor, height: 1.2)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 删除（右组在设计稿中略低于圆心，约 +1.5）
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDelete,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, size: 22, color: _grayColor),
                        SizedBox(width: 0.5),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('删除', style: TextStyle(fontSize: 14, color: _grayColor, height: 1.2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 默认地址指示圆点：选中为蓝色实心 + 白色对勾；未选中为灰色圆环
  Widget _buildDefaultIndicator() {
    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: address.isDefault ? _defaultColor : Colors.white,
        shape: BoxShape.circle,
        border: address.isDefault ? null : Border.all(color: _grayColor),
      ),
      child: address.isDefault ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
    );
  }
}
