import 'package:flutter/material.dart';

/// 青轻生活馆阴影规范
abstract final class AppShadows {
  static const Shadow sm = Shadow(
    color: Color(0x1A000000),
    offset: Offset(0, 2),
    blurRadius: 4,
  );

  static const Shadow md = Shadow(
    color: Color(0x1F000000),
    offset: Offset(0, 4),
    blurRadius: 12,
  );

  static const Shadow lg = Shadow(
    color: Color(0x24000000),
    offset: Offset(0, 8),
    blurRadius: 24,
  );

  static List<Shadow> toList(Shadow shadow) => [shadow];
}
