import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../member/domain/repositories/member_repository.dart';

/// 确认订单顶部导航栏（使用 Flutter AppBar）
class ConfirmOrderNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const ConfirmOrderNavBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 22),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
      title: const Text(
        '确认订单',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
      ),
    );
  }
}

/// 确认订单顶部地址卡片（导航栏 + 地址信息/无地址新建入口）
class ConfirmOrderHeader extends StatelessWidget {
  final MemberAddress? address;
  final bool isLoading;
  final VoidCallback? onAddAddress;
  final VoidCallback? onEditAddress;

  const ConfirmOrderHeader({super.key, this.address, this.isLoading = false, this.onAddAddress, this.onEditAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.0))),
            )
          : address == null
          ? _buildEmptyAddressCard(context)
          : _buildAddressCard(context, address!),
    );
  }

  Widget _buildEmptyAddressCard(BuildContext context) {
    return GestureDetector(
      onTap: onAddAddress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 28),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Color(0xFFF3F5F7), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Color(0xFF213775), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '暂无收货地址',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
                  ),
                  SizedBox(height: 2),
                  Text('请先添加收货地址以接收实物商品', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E97))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF213775)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, MemberAddress addr) {
    final regionText = '${addr.province} ${addr.city} ${addr.district}'.trim();
    final detailText = addr.detail;
    final contactText = '${addr.name}  ${addr.phone}';

    return GestureDetector(
      onTap: onEditAddress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/points/confirm_order_location.png',
                  width: 18,
                  height: 18,
                  errorBuilder: (_, _, _) => const Icon(Icons.location_on, size: 18, color: Color(0xFF213775)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    regionText,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    detailText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '修改地址>',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF213775)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              contactText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF1F2024)),
            ),
          ],
        ),
      ),
    );
  }
}
