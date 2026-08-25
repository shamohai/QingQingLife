import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_radius.dart';

class HomeBanner extends StatefulWidget {
  final List<String> imageUrls;
  const HomeBanner({super.key, required this.imageUrls});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() { super.initState(); _controller = PageController(initialPage: 0); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: widget.imageUrls[index], fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.imageUrls.length, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: _currentPage == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF2E7D52) : const Color(0xFFC4C8BF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ),
      ],
    );
  }
}
