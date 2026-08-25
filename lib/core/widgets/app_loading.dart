import 'package:flutter/material.dart';

/// 居中加载指示器
class AppLoading extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;

  const AppLoading({super.key, this.color, this.strokeWidth = 2.5});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}