import 'package:flutter/material.dart';

import 'cart_design_tokens.dart';

class CartSelectionControl extends StatelessWidget {
  const CartSelectionControl({super.key, required this.selected, required this.onTap, this.size = 22});

  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? const Color(0xFF0D96FF) : Colors.white,
            border: Border.all(color: selected ? const Color(0xFF0D96FF) : CartDesignTokens.muted, width: 1.2),
          ),
          child: selected ? Icon(Icons.check_rounded, size: size * 0.7, color: Colors.white) : null,
        ),
      ),
    );
  }
}
