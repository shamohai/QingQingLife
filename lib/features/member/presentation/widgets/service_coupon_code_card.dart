import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/service_coupon_model.dart';

class ServiceCouponCodeCard extends StatelessWidget {
  final ServiceCouponInfo coupon;
  final VoidCallback? onTransfer;
  final VoidCallback? onDeliver;

  const ServiceCouponCodeCard({super.key, required this.coupon, this.onTransfer, this.onDeliver});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E7E7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            color: const Color(0xFF243A78),
            child: Text(
              coupon.couponName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    if (coupon.canTransfer) _CodeActionButton(label: '立即转赠', onTap: onTransfer),
                    const Spacer(),
                    if (coupon.canDeliver) _CodeActionButton(label: '快递到家', onTap: onDeliver),
                  ],
                ),
                const SizedBox(height: 15),
                _RemoteCodeImage(url: coupon.barcodeUrl, height: 58, placeholderIcon: Icons.view_week_outlined),
                const SizedBox(height: 5),
                Text(
                  coupon.couponSn,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF1A1D1C), height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                _RemoteCodeImage(url: coupon.qrUrl, width: 148, height: 148, placeholderIcon: Icons.qr_code_2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _CodeActionButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E6EB5)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2E6EB5), height: 1.2),
        ),
      ),
    );
  }
}

class _RemoteCodeImage extends StatelessWidget {
  final String url;
  final double? width;
  final double height;
  final IconData placeholderIcon;

  const _RemoteCodeImage({required this.url, this.width, required this.height, required this.placeholderIcon});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      width: width ?? double.infinity,
      height: height,
      fit: BoxFit.contain,
      placeholder: (_, _) => _placeholder(),
      errorWidget: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Icon(placeholderIcon, size: height * 0.7, color: const Color(0xFFB8B8B8)),
    );
  }
}
