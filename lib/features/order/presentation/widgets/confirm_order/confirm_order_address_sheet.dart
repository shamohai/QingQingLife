import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../member/domain/repositories/member_repository.dart';
import '../../../../member/presentation/providers/member_addresses_provider.dart';

/// 确认订单页收货地址选择底部弹层。
class MallConfirmOrderAddressSheet extends ConsumerWidget {
  const MallConfirmOrderAddressSheet({
    super.key,
    required this.selectedAddressId,
    required this.bottomInset,
    required this.onSelect,
    required this.onCreate,
  });

  final String? selectedAddressId;
  final double bottomInset;
  final ValueChanged<MemberAddress> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(memberAddressesProvider);
    return Column(
      children: [
        Padding(
   padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
   child: SizedBox(
     height: 30,
            child: Stack(
alignment: Alignment.center,
       children: [
         const Text('收货地址', style: TextStyle(fontSize: 20, height: 1.4, color: Colors.black)),
  Align(
           alignment: Alignment.centerRight,
    child: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      tooltip: '关闭',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: const Icon(Icons.close, size: 28, color: Color(0xFF303030)),
    ),
         ),
       ],
     ),
          ),
        ),
 const SizedBox(height: 20),
        Expanded(
   child: addresses.when(
     data: (items) => items.isEmpty
         ? const Center(child: Text('暂无收货地址', style: TextStyle(fontSize: 16)))
         : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final address = items[index];
        return Padding(
   padding: const EdgeInsets.only(bottom: 14),
   child: _AddressChoice(address: address, selected: address.id == selectedAddressId, onTap: () => onSelect(address)),
        );
      },
    ),
     loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
       child: TextButton(onPressed: () => ref.invalidate(memberAddressesProvider), child: const Text('地址加载失败，点击重试')),
     ),
   ),
 ),
        Container(
          height: 80,
   padding: const EdgeInsets.fromLTRB(30, 15, 30, 14),
   decoration: const BoxDecoration(
     color: Colors.white,
     boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
          ),
          child: SizedBox(
     width: double.infinity,
     height: 51,
            child: DecoratedBox(
decoration: BoxDecoration(
  gradient: const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.serviceTabActive, AppColors.serviceCtaGradStart],
         ),
  borderRadius: BorderRadius.circular(100),
       ),
child: TextButton(
  onPressed: onCreate,
         style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: const StadiumBorder()),
  child: const Text(
    '创建新地址',
    style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.white),
         ),
       ),
     ),
   ),
 ),
        SizedBox(height: bottomInset),
      ],
    );
  }
}

class _AddressChoice extends StatelessWidget {
  const _AddressChoice({required this.address, required this.selected, required this.onTap});

  final MemberAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 98),
 padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
   color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.serviceProjectBlue : Colors.transparent),
        ),
        child: Row(
          children: [
     Expanded(
child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisSize: MainAxisSize.min,
         children: [
    Wrap(
      spacing: 10,
      runSpacing: 2,
      children: [
        Text(
   address.name,
          style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: selected ? AppColors.serviceTabActive : Colors.black),
        ),
 Text(
          address.phone.replaceAll(' ', ''),
   style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: selected ? AppColors.serviceTabActive : Colors.black),
        ),
      ],
    ),
    const SizedBox(height: 6),
    Text(address.fullAddress, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black)),
         ],
       ),
     ),
     const SizedBox(width: 12),
     Container(
       width: 30,
       height: 30,
       decoration: BoxDecoration(
  color: selected ? AppColors.serviceProjectBlue : Colors.white,
         shape: BoxShape.circle,
  border: Border.all(color: selected ? AppColors.serviceProjectBlue : const Color(0xFF8E8E93)),
       ),
       child: selected ? const Icon(Icons.check, size: 22, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}
