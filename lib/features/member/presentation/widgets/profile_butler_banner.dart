import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../points/mall/presentation/utils/butler_mini_program_launcher.dart';

/// 管家服务运营 Banner
///
/// 视觉素材：assets/images/member/butler_service_banner.webp（设计稿切图）。
class ProfileButlerBanner extends ConsumerWidget {
  const ProfileButlerBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => launchButlerMiniProgram(context, ref),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 364 / 69,
          child: Image.asset('assets/images/member/butler_service_banner.webp', width: double.infinity, fit: BoxFit.cover, alignment: Alignment.center),
        ),
      ),
    );
  }
}
