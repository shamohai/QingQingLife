import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';

/// 用户头像统一展示组件。
///
/// 上传成功后优先展示本地预览，避免头像 URL 未变化时仍命中旧网络缓存。
class UserAvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final Uint8List? previewBytes;
  final double size;
  final BoxFit fit;
  final double? iconSize;

  const UserAvatarImage({super.key, required this.avatarUrl, required this.previewBytes, required this.size, this.fit = BoxFit.cover, this.iconSize});

  @override
  Widget build(BuildContext context) {
    if (previewBytes != null && previewBytes!.isNotEmpty) {
      final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
      return Image.memory(
        previewBytes!,
        width: size,
        height: size,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
      );
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return AppNetworkImage(url: avatarUrl!, width: size, height: size, fit: fit);
    }

    return Icon(Icons.person_outline, size: iconSize ?? size * 0.48, color: const Color(0xFF8FA8BF));
  }
}
