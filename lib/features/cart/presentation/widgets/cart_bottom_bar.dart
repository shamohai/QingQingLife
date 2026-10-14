import 'package:flutter/material.dart';

import '../providers/cart_page_provider.dart';
import 'cart_design_tokens.dart';
import 'cart_selection_control.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key, required this.state, required this.onToggleAll, required this.onPrimaryAction, required this.onClearAll});

  final CartPageState state;
  final ValueChanged<bool> onToggleAll;
  final VoidCallback onPrimaryAction;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final actionEnabled = state.hasSelectedItems;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth * 0.355).clamp(118.0, 156.0);

            return SizedBox(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onToggleAll(!state.allSelected),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CartSelectionControl(selected: state.allSelected, onTap: () => onToggleAll(!state.allSelected)),
                            const SizedBox(width: 5),
                            const Text('全选', style: TextStyle(color: CartDesignTokens.muted, fontSize: 14, height: 1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: state.isManaging
                          ? _ManagementActions(deleteEnabled: actionEnabled, onClearAll: onClearAll, onDelete: onPrimaryAction, buttonWidth: buttonWidth)
                          : _SettlementAction(enabled: actionEnabled, buttonWidth: buttonWidth, onPressed: onPrimaryAction, state: state),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class _ManagementActions extends StatelessWidget {
  const _ManagementActions({required this.deleteEnabled, required this.onClearAll, required this.onDelete, required this.buttonWidth});

  final bool deleteEnabled;
  final VoidCallback onClearAll;
  final VoidCallback onDelete;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Semantics(
            button: true,
            label: '一键清空购物车',
            child: TextButton.icon(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: CartDesignTokens.muted,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 21),
              label: const Text(
                '一键清空',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          enabled: deleteEnabled,
          label: '删除选中商品',
          child: OutlinedButton(
            onPressed: deleteEnabled ? onDelete : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: deleteEnabled ? CartDesignTokens.primary : CartDesignTokens.muted,
              side: BorderSide(color: deleteEnabled ? CartDesignTokens.primary : CartDesignTokens.faint),
              minimumSize: Size(buttonWidth, 47),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const StadiumBorder(),
            ),
            child: const Text('删除', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

class _SettlementAction extends StatelessWidget {
  const _SettlementAction({required this.enabled, required this.buttonWidth, required this.onPressed, required this.state});

  final bool enabled;
  final double buttonWidth;
  final VoidCallback onPressed;
  final CartPageState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SettlementSummary(state: state)),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          enabled: enabled,
          label: '立即结算',
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(100),
            child: Ink(
              width: buttonWidth,
              height: 47,
              decoration: BoxDecoration(
                gradient: enabled
                    ? const LinearGradient(colors: [CartDesignTokens.primary, CartDesignTokens.primaryEnd])
                    : const LinearGradient(colors: [Color(0xFFB8BDC9), Color(0xFFA4AAB7)]),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Center(
                child: Text(
                  '立即结算',
                  style: TextStyle(color: Colors.white, fontSize: 18, height: 1, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettlementSummary extends StatelessWidget {
  const _SettlementSummary({required this.state});

  final CartPageState state;

  @override
  Widget build(BuildContext context) {
    final value = (state.selectedPayableCents / 100).toStringAsFixed(2);
    final savedYuan = (state.selectedSavingsCents / 100).toStringAsFixed(0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '合计：',
                  style: TextStyle(color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.w400),
                ),
                const TextSpan(text: '¥', style: TextStyle(fontSize: 16)),
                TextSpan(text: value),
              ],
            ),
            maxLines: 1,
            style: const TextStyle(color: CartDesignTokens.summary, fontSize: 24, height: 1, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 6),
        Text('共减免$savedYuan元', maxLines: 1, style: const TextStyle(color: CartDesignTokens.summary, fontSize: 12, height: 1)),
      ],
    );
  }
}
