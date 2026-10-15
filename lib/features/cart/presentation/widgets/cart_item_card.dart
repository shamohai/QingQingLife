import 'package:flutter/material.dart';

import '../../domain/models/cart_page_models.dart';
import 'cart_design_tokens.dart';
import 'cart_product_image.dart';
import 'cart_selection_control.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item, required this.onToggle, required this.onQuantityChanged});

  final CartDisplayItem item;
  final VoidCallback onToggle;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = (constraints.maxWidth * 0.284).clamp(96.0, 112.0);
        final compact = constraints.maxWidth < 370;

        return SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CartSelectionControl(selected: item.selected, onTap: onToggle),
                ),
              ),
              CartProductImage(variant: CartProductImageVariant.thumbnail, width: imageSize, height: imageSize, fit: BoxFit.contain, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductTitle(item: item, compact: compact),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _OutlineTag(label: item.volumeLabel),
                        const SizedBox(width: 8),
                        _OutlineTag(label: item.flavorLabel),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: _CartPrice(cents: item.priceCents)),
                        _QuantitySelector(quantity: item.quantity, compact: compact, onChanged: onQuantityChanged),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductTitle extends StatelessWidget {
  const _ProductTitle({required this.item, required this.compact});

  final CartDisplayItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: 34,
              child: Container(
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: CartDesignTokens.primary, borderRadius: BorderRadius.circular(2)),
                child: const Text(
                  '自营',
                  style: TextStyle(color: Colors.white, fontSize: 10, height: 1, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          TextSpan(text: ' ${item.name}'),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: const Color(0xFF111111), fontSize: compact ? 14.5 : 16, height: 1.45, fontWeight: FontWeight.w400),
    );
  }
}

class _OutlineTag extends StatelessWidget {
  const _OutlineTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: CartDesignTokens.price),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: CartDesignTokens.price, fontSize: 11.5, height: 1, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _CartPrice extends StatelessWidget {
  const _CartPrice({required this.cents});

  final int cents;

  @override
  Widget build(BuildContext context) {
    final value = (cents / 100).toStringAsFixed(2);
    final parts = value.split('.');

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '¥',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            TextSpan(text: parts.first),
            TextSpan(
              text: '.${parts.last}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        maxLines: 1,
        style: const TextStyle(color: CartDesignTokens.price, fontSize: 21, height: 1, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity, required this.compact, required this.onChanged});

  final int quantity;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final controlSize = compact ? 30.0 : 34.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuantityButton(icon: Icons.remove_rounded, size: controlSize, enabled: quantity > 1, onTap: () => onChanged(quantity - 1)),
        SizedBox(
          width: compact ? 24 : 30,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF111111), fontSize: 18, height: 1, fontWeight: FontWeight.w500),
          ),
        ),
        _QuantityButton(icon: Icons.add_rounded, size: controlSize, onTap: () => onChanged(quantity + 1)),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.size, required this.onTap, this.enabled = true});

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CartDesignTokens.controlBackground,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: enabled ? const Color(0xFF111111) : const Color(0xFFC7C9CD)),
        ),
      ),
    );
  }
}
