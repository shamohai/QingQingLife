import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../features/member/domain/repositories/member_repository.dart';
import '../../../../features/member/presentation/providers/member_addresses_provider.dart';

/// 购酒享服务地址选择底部面板
class ServiceCartAddressSheet extends StatelessWidget {
  final MemberAddress? selectedAddress;
  final ValueChanged<MemberAddress> onSelectAddress;
  final VoidCallback onCreateNewAddress;

  const ServiceCartAddressSheet({super.key, this.selectedAddress, required this.onSelectAddress, required this.onCreateNewAddress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 648,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: Column(
          children: [
            // 拖拽条
            SizedBox(
              height: 29,
              child: Center(
                child: Container(
                  width: 250,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            // 标题行
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  const Text(
                    '收货地址',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, size: 24), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            // 地址列表
            Expanded(
              child: _AddressListView(selectedAddress: selectedAddress, onSelectAddress: onSelectAddress),
            ),
            // 创建新地址按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                  ),
                  onPressed: onCreateNewAddress,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                      gradient: LinearGradient(colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive]),
                    ),
                    child: const Center(
                      child: Text(
                        '创建新地址',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressListView extends ConsumerWidget {
  final MemberAddress? selectedAddress;
  final ValueChanged<MemberAddress> onSelectAddress;

  const _AddressListView({required this.selectedAddress, required this.onSelectAddress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(memberAddressesProvider);
    return addressesAsync.when(
      data: (addresses) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: addresses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return _AddressCardItem(address: addr, isSelected: addr.id == selectedAddress?.id, onTap: () => onSelectAddress(addr));
        },
      ),
      loading: () => const Center(child: AppLoading()),
      error: (_, _) => const Center(
        child: Text('加载地址失败，请重试', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _AddressCardItem extends StatelessWidget {
  final MemberAddress address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressCardItem({required this.address, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 98,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF0088FF), width: 1.5) : null,
        ),
        child: Stack(
          children: [
            // 姓名 + 手机号
            Positioned(
              left: 10,
              top: 10,
              child: Row(
                children: [
                  Text(
                    address.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    address.phone,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ],
              ),
            ),
            // 省市区
            Positioned(
              left: 10,
              top: 42,
              child: Text('${address.province} ${address.city} ${address.district}', style: const TextStyle(fontSize: 16, color: Colors.black)),
            ),
            // 详细地址
            Positioned(
              left: 10,
              top: 64,
              child: Text(address.detail, style: const TextStyle(fontSize: 16, color: Colors.black)),
            ),
            Positioned(
              right: 10,
              top: 34,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0088FF) : Colors.white,
                  shape: BoxShape.circle,
                  border: isSelected ? null : Border.all(color: AppColors.outlineVariant, width: 1.5),
                ),
                child: isSelected ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white)) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
