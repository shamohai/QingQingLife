import 'package:flutter/material.dart';

import 'cart_design_tokens.dart';

class CartPageHeader extends StatelessWidget {
  const CartPageHeader({
    super.key,
    required this.address,
    required this.isManaging,
    required this.hasItems,
    required this.onBack,
    required this.onAddressTap,
    required this.onManageTap,
  });

  final String address;
  final bool isManaging;
  final bool hasItems;
  final VoidCallback onBack;
  final VoidCallback onAddressTap;
  final VoidCallback onManageTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      tooltip: '返回',
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Color(0xFF111111)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                    const Text(
                      '购物车',
                      style: TextStyle(color: Color(0xFF111111), fontSize: 18, height: 1, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (hasItems)
                      TextButton(
                        onPressed: onManageTap,
                        style: TextButton.styleFrom(
                          foregroundColor: CartDesignTokens.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(48, 40),
                        ),
                        child: Text(isManaging ? '完成' : '管理', style: const TextStyle(fontSize: 16, height: 1, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddressTap,
                child: SizedBox(
                  height: 42,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 18, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 23, color: Color(0xFF5373BC)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: CartDesignTokens.muted, fontSize: 14, height: 1.2, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: CartDesignTokens.muted),
                      ],
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
