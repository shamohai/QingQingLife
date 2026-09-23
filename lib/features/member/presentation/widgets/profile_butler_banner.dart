import 'package:flutter/material.dart';

/// 管家服务运营 Banner
///
/// 视觉素材：assets/images/member/butler_service_banner.webp（设计稿切图）。
/// 点击跳转管家服务页 —— 路由暂未实现，保留 TODO。
class ProfileButlerBanner extends StatelessWidget {
  const ProfileButlerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 管家服务页路由待实现
        debugPrint('[ProfileButlerBanner] 管家服务 Banner 点击');
      },
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
