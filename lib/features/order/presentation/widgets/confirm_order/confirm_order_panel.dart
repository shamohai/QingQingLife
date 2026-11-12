import 'package:flutter/material.dart';

import '../../../../../app/theme/app_radius.dart';

class MallConfirmOrderPanel extends StatelessWidget {
  const MallConfirmOrderPanel({super.key, required this.height, required this.child, this.padding = const EdgeInsets.all(10)});

  final double height;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: child,
    );
  }
}
