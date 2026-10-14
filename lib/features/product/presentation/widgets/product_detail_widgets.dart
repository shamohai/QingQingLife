import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/product_detail_content.dart';

const _blue = AppColors.serviceTabActive;
const _red = AppColors.serviceButtonRed;
const _muted = Color(0xFF8E8E93);

TextStyle _t(double size, {Color color = Colors.black, FontWeight weight = FontWeight.w400, double height = 1.4}) =>
    AppTextStyles.bodyMedium.copyWith(fontSize: size, color: color, fontWeight: weight, height: height);

class ProductHero extends StatefulWidget {
  final List<String> images;
  final VoidCallback onBack;
  const ProductHero({super.key, required this.images, required this.onBack});

  @override
  State<ProductHero> createState() => _ProductHeroState();
}

class _ProductHeroState extends State<ProductHero> with WidgetsBindingObserver {
  static const _autoplayInterval = Duration(seconds: 3);
  static const _transitionDuration = Duration(milliseconds: 400);
  late final PageController _pageController;
  Timer? _autoplayTimer;
  int _currentIndex = 0;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    // 从中间开始，首张也可以向右滑动，末张向左自然衔接首张。
    _pageController = PageController(initialPage: widget.images.length * 1000);
    WidgetsBinding.instance.addObserver(this);
    _startAutoplay();
  }

  @override
  void didUpdateWidget(covariant ProductHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.images, widget.images)) {
      _currentIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(widget.images.length * 1000);
        }
      });
      _startAutoplay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoplay();
    } else {
      _autoplayTimer?.cancel();
    }
  }

  void _startAutoplay() {
    _autoplayTimer?.cancel();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (widget.images.length < 2 || _isInteracting || (lifecycle != null && lifecycle != AppLifecycleState.resumed)) return;
    _autoplayTimer = Timer.periodic(_autoplayInterval, (_) {
      if (!mounted || !_pageController.hasClients || !TickerMode.valuesOf(context).enabled || _pageController.position.isScrollingNotifier.value) return;
      final nextPage = (_pageController.page ?? _pageController.initialPage.toDouble()).round() + 1;
      _pageController.animateToPage(nextPage, duration: _transitionDuration, curve: Curves.easeInOut);
    });
  }

  void _endInteraction() {
    _isInteracting = false;
    _startAutoplay();
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.images.isEmpty
                ? const SizedBox.shrink()
                : widget.images.length == 1
                ? AppNetworkImage(url: widget.images.first, fit: BoxFit.contain)
                : Listener(
                    onPointerDown: (_) {
                      _isInteracting = true;
                      _autoplayTimer?.cancel();
                    },
                    onPointerUp: (_) => _endInteraction(),
                    onPointerCancel: (_) => _endInteraction(),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        if (widget.images.length < 2) return;
                        setState(() => _currentIndex = page % widget.images.length);
                        _startAutoplay();
                      },
                      itemBuilder: (context, page) => AppNetworkImage(url: widget.images[page % widget.images.length], fit: BoxFit.contain),
                    ),
                  ),
          ),
          Positioned(
            left: 24,
            top: 12,
            child: Material(
              color: Colors.black.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: widget.onBack,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '商品详情',
                          style: _t(18, color: Colors.white, weight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
                    key: ValueKey('product-hero-dot-$i'),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: i == _currentIndex ? const Color(0xFF0088FF) : Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PriceBenefits extends StatelessWidget {
  final ProductDetailContent detail;
  final VoidCallback onCoupon;
  const PriceBenefits({super.key, required this.detail, required this.onCoupon});

  @override
  Widget build(BuildContext context) {
    final price = Money(detail.product.priceCents).toYuanString().split('.');
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(colors: [Color(0xFFFF3C0C), Color(0xFFFF9564)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.product.name,
                  style: _t(20, color: Colors.white, weight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: ['52%vol', '清香型']
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(tag, style: _t(12, color: Colors.white)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '¥',
                        style: _t(18, color: Colors.white, weight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: price.first,
                            style: _t(32, color: Colors.white, weight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '.${price.last}',
                            style: _t(18, color: Colors.white, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                      child: Text('会员价:${Money(detail.memberPriceCents).toYuanString()}', style: _t(14, color: _red)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('原价:${Money(detail.product.originalPriceCents!).format()}', style: _t(16, color: Colors.white)),
                    Text('已售:${detail.salesLabel}', style: _t(16, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 1, 10, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(detail.product.description, style: _t(14, height: 1.5)),
                const SizedBox(height: 15),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                InkWell(
                  onTap: onCoupon,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(8)),
                          child: Text('优惠券中心', style: _t(14, color: Colors.white)),
                        ),
                        Text('去领取>', style: _t(14, color: _red)),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFFFEDD9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const AppNetworkImage(url: 'assets/images/product/crown.png', width: 23, height: 23, fit: BoxFit.contain),
                      const SizedBox(width: 10),
                      Text(
                        '清香型酒类TOP1',
                        style: _t(16, color: const Color(0xFFD39858), weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text('未满18周岁的用户请勿购买本商品;孕妇请勿饮酒;酒后请勿驾车。', style: _t(12, color: _muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsSection extends StatelessWidget {
  final ProductDetailContent detail;
  final VoidCallback onViewAll;
  const ReviewsSection({super.key, required this.detail, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 94,
                        height: 7,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          gradient: LinearGradient(colors: [Color(0xFF0088FF), Color(0x00F3F5F7)]),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: '商品评价',
                        style: _t(18, weight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: '（${detail.reviewCount}）',
                            style: _t(12, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewAll,
                child: Text('查看全部>>>', style: _t(14, color: _muted)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < detail.reviews.length; i++) ...[if (i > 0) const SizedBox(height: 20), ReviewItem(review: detail.reviews[i])],
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final ProductReview review;
  const ReviewItem({super.key, required this.review});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          AppNetworkImage(url: review.avatar, width: 26, height: 26, radius: 13),
          const SizedBox(width: 4),
          Text(review.name, style: _t(16)),
          const SizedBox(width: 10),
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.star_rounded, size: 17, color: i < review.rating ? _red : const Color(0xFFD9D9D9)),
              ),
            ),
          ),
          const Spacer(),
          Text(review.timeLabel, style: _t(16, color: _muted)),
        ],
      ),
      const SizedBox(height: 14),
      Text(review.content, style: _t(16, height: 1.4)),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: review.photosWidth,
          height: 70,
          child: AppNetworkImage(url: review.photos, fit: BoxFit.fill),
        ),
      ),
    ],
  );
}

class DetailSection extends StatelessWidget {
  final String image;
  const DetailSection({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: 94,
                  height: 7,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    gradient: LinearGradient(colors: [Color(0xFF0088FF), Color(0x00F3F5F7)]),
                  ),
                ),
              ),
              Text('商品详情', style: _t(18, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 395 / 600,
            child: AppNetworkImage(url: image, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class PurchaseBar extends StatelessWidget {
  final VoidCallback onHome, onService, onCart, onAdd, onBuy;
  const PurchaseBar({super.key, required this.onHome, required this.onService, required this.onCart, required this.onAdd, required this.onBuy});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16.5),
        child: Row(
          children: [
            _Nav(label: '首页', icon: const Icon(CupertinoIcons.house, size: 24), onTap: onHome),
            _Nav(label: '客服', icon: const Icon(CupertinoIcons.headphones, size: 24), onTap: onService),
            _Nav(
              label: '购物车',
              icon: const AppNetworkImage(url: 'assets/images/product/detail-cart.png', width: 25, height: 24),
              onTap: onCart,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Row(
                  children: [
                    Expanded(
                      flex: 130,
                      child: _Cta(label: '加入购物车', color: _blue, onTap: onAdd),
                    ),
                    Expanded(
                      flex: 112,
                      child: _Cta(label: '立即购买', color: _blue, onTap: onBuy),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Nav extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const _Nav({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext c) => SizedBox(
    width: 44,
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 8),
          Text(label, style: _t(14, weight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

class _Cta extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Cta({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext c) => Material(
    color: label == '立即购买' ? color : color.withValues(alpha: .1),
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 47,
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: Text(
              label,
              maxLines: 1,
              style: _t(
                constraints.maxWidth < 90
                    ? 14
                    : constraints.maxWidth < 105
                    ? 16
                    : 18,
                color: label == '立即购买' ? Colors.white : color,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
