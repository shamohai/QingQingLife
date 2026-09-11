import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../domain/models/service_card_data.dart';
import '../providers/service_provider.dart';

class ServicePage extends ConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(serviceCardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _HeaderRow(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: cards.isEmpty
                      ? const AppEmpty(message: '暂无服务')
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: cards.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => _ServiceCard(data: cards[index]),
                        ),
                ),
              ],
            ),
          ),
          _FloatingButtons(),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 10,
              child: Container(
                width: 94,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF0088FF), Color(0x000088FF)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: const Text(
                '服务预约',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 11,
              child: TextButton(
                onPressed: () => context.push(RouteNames.serviceRecords),
                child: const Text(
                  '预约/报名记录',
                  style: TextStyle(fontSize: 14, color: Color(0xFF0088FF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceCardData data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                data.imageAsset,
                width: 170,
                height: 104,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 170,
                  height: 104,
                  child: Center(child: Icon(Icons.image_outlined, size: 40, color: Color(0xFF8E8E97))),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 21, right: 66),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF8E8E97)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: 92,
                    height: 30,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF2105)),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        data.buttonText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFF2105)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSpacing.md,
      top: MediaQuery.of(context).padding.top + 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FabCircleWidget(icon: Icons.shopping_cart, onTap: () => context.push(RouteNames.serviceCart)),
          const SizedBox(height: 10),
          _FabCircleWidget(icon: Icons.my_location, onTap: () {}),
        ],
      ),
    );
  }
}

class _FabCircleWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FabCircleWidget({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 29,
        height: 30,
        decoration: const BoxDecoration(color: Color(0xFF213771), shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}
