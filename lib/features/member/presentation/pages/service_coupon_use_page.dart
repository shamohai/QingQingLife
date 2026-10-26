import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../data/models/service_coupon_model.dart';
import '../providers/service_coupon_use_provider.dart';
import '../widgets/service_coupon_code_card.dart';
import '../widgets/service_coupon_transfer_dialog.dart';

/// 服务券到店兑换页（/coupons/service/use）
class ServiceCouponUsePage extends ConsumerStatefulWidget {
  final ServiceCouponInfo coupon;

  const ServiceCouponUsePage({super.key, required this.coupon});

  @override
  ConsumerState<ServiceCouponUsePage> createState() => _ServiceCouponUsePageState();
}

class _ServiceCouponUsePageState extends ConsumerState<ServiceCouponUsePage> {
  late final TextEditingController _countController;
  bool _handledUsed = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: '1');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceCouponUseProvider.notifier).initialize(widget.coupon);
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ServiceCouponUseState>(serviceCouponUseProvider, (previous, next) {
      final inputCount = int.tryParse(_countController.text);
      if (inputCount != next.count) _setCountText(next.count);
      if (next.used && !_handledUsed) {
        _handledUsed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleUsed());
      }
    });
    final state = ref.watch(serviceCouponUseProvider);
    final coupon = state.coupon ?? widget.coupon;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.white),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNavBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                      child: Column(
                        children: [
                          ServiceCouponCodeCard(coupon: coupon, onTransfer: _handleTransfer, onDeliver: _handleDeliver),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCountCard(state),
                          if (coupon.remark.trim().isNotEmpty) ...[const SizedBox(height: AppSpacing.sm), _buildDescriptionCard(coupon)],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: AppSpacing.md),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF000000)),
            ),
          ),
          const Text(
            '服务券兑换',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(ServiceCouponUseState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _cardDecoration,
      child: Row(
        children: [
          const Text(
            '您即将使用',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (value) {
                final count = int.tryParse(value) ?? 1;
                final maxCount = ref.read(serviceCouponUseProvider.notifier).setCount(count);
                if (maxCount != null) {
                  _setCountText(maxCount);
                  _showMaxCountMessage(maxCount);
                }
              },
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF2E6EB5)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            '张服务券',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
          ),
          if (state.errorMessage != null) ...[const Spacer(), const Icon(Icons.sync_problem, size: 16, color: Color(0xFFFF8A3D))],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ServiceCouponInfo coupon) {
    final remark = coupon.remark.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用说明',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            remark,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF555555), height: 1.2),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE7E7E7)),
    borderRadius: BorderRadius.circular(8),
  );

  Future<void> _handleUsed() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('使用成功'),
          content: const Text('服务券已核销使用'),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('确定'))],
        ),
      ),
    );
    if (!mounted) return;
    context.pop(true);
  }

  Future<void> _handleTransfer() async {
    final coupon = ref.read(serviceCouponUseProvider).coupon ?? widget.coupon;
    final result = await runServiceCouponTransferFlow(context: context, ref: ref, coupon: coupon);
    if (!mounted || result?.success != true) return;
    context.pop();
  }

  Future<void> _handleDeliver() async {
    final state = ref.read(serviceCouponUseProvider);
    final coupon = state.coupon ?? widget.coupon;
    if (coupon.serviceCouponId <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('服务券信息无效，请刷新后重试'), behavior: SnackBarBehavior.floating));
      return;
    }
    final count = state.count > 0 ? state.count : 1;
    await context.push(RouteNames.serviceCouponConfirmOrderPath(serviceCouponId: coupon.serviceCouponId, count: count));
  }

  void _setCountText(int count) {
    final text = '$count';
    if (_countController.text == text) return;
    _countController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _showMaxCountMessage(int maxCount) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('最多可使用$maxCount张'), behavior: SnackBarBehavior.floating));
  }
}
