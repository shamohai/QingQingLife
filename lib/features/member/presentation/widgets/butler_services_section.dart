import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  const _ServiceItem({required this.icon, required this.label, required this.bgColor});
}

class ButlerServicesSection extends StatelessWidget {
  const ButlerServicesSection({super.key});

  static const _items = [
    _ServiceItem(icon: Icons.local_offer, label: '领券中心', bgColor: AppColors.primaryContainer),
    _ServiceItem(icon: Icons.location_on_outlined, label: '收货地址', bgColor: const Color(0xFFE3F2FD)),
    _ServiceItem(icon: Icons.support_agent, label: '客服中心', bgColor: AppColors.primaryContainer),
    _ServiceItem(icon: Icons.receipt_long_outlined, label: '我的发票', bgColor: const Color(0xFFFFF3E0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('专属管家服务', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: _items.map((item) => _ServiceCell(item: item)).toList(),
              ),
            ],
          ),
          Positioned(
            right: 16,
            top: -4,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: [const BoxShadow(color: Color(0x292E7D52), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 14, color: AppColors.primary),
                    Text('管家', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w600, height: 1.1)),
                    Text('服务', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w600, height: 1.1)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCell extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCell({required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: item.bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(item.icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(item.label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
