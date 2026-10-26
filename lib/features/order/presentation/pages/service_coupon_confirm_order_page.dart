import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../member/domain/repositories/member_repository.dart';
import '../../../member/presentation/providers/member_addresses_provider.dart';
import '../../../points_mall/presentation/widgets/confirm_order_header.dart';
import '../../domain/entities/service_coupon_order.dart';
import '../providers/service_coupon_order_provider.dart';
import 'mall_payment_success_page.dart';

/// 服务券支付订单确认页。
///
/// 页面数据全部来自服务券订单预处理接口，商品可兑换数量只读展示，不可在本页修改。
class ServiceCouponConfirmOrderPage extends ConsumerStatefulWidget {
  const ServiceCouponConfirmOrderPage({super.key, required this.serviceCouponId, this.initialCount = 1});

  final int serviceCouponId;
  final int initialCount;

  @override
  ConsumerState<ServiceCouponConfirmOrderPage> createState() => _ServiceCouponConfirmOrderPageState();
}

class _ServiceCouponConfirmOrderPageState extends ConsumerState<ServiceCouponConfirmOrderPage> {
  late final TextEditingController _remarkController;
  int _requestedCouponCount = 1;
  int? _selectedAddressId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _requestedCouponCount = widget.initialCount > 0 ? widget.initialCount : 1;
    _remarkController = TextEditingController();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceCouponId <= 0) {
      return _buildScaffold(body: const AppError(message: '服务券信息无效，请返回后重试'));
    }

    final query = (serviceCouponId: widget.serviceCouponId, count: _requestedCouponCount, addressId: _selectedAddressId);
    final preDealAsync = ref.watch(serviceCouponPreDealProvider(query));
    return preDealAsync.when(
      loading: () => _buildScaffold(body: const Center(child: AppLoading())),
      error: (error, stack) => _buildScaffold(
        body: AppError(message: '订单信息加载失败，请稍后重试', onRetry: () => ref.invalidate(serviceCouponPreDealProvider(query))),
      ),
      data: (preDeal) {
        final effectiveCount = _effectiveCouponCount(preDeal);
        return _buildScaffold(
          body: _buildContent(preDeal, effectiveCount),
          bottomNavigationBar: _ServiceCouponOrderBottomBar(
            amount: preDeal.totalAmount,
            discount: preDeal.totalDiscount,
            enabled: !_isSubmitting && effectiveCount > 0 && _resolveSubmitAddressId(preDeal) != null,
            submitting: _isSubmitting,
            onSubmit: () => _submit(preDeal, effectiveCount),
          ),
        );
      },
    );
  }

  Scaffold _buildScaffold({required Widget body, Widget? bottomNavigationBar}) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: ConfirmOrderNavBar(onBack: () => context.pop()),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildContent(ServiceCouponPreDealData preDeal, int effectiveCount) {
    return RefreshIndicator(
      color: AppColors.serviceTabActive,
      onRefresh: () async {
        ref.invalidate(serviceCouponPreDealProvider((serviceCouponId: widget.serviceCouponId, count: _requestedCouponCount, addressId: _selectedAddressId)));
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
        child: Column(
          children: [
            if (!preDeal.dontShowAddress) ...[
              _ServiceCouponAddressCard(address: preDeal.shipAddress, onEditAddress: () => _showAddressPicker(preDeal.shipAddress)),
              const SizedBox(height: 10),
            ],
            _ServiceCouponQuantityCard(
              count: effectiveCount,
              maxCount: preDeal.maxCouponCount,
              onDecrement: effectiveCount > 1 ? () => setState(() => _requestedCouponCount = effectiveCount - 1) : null,
              onIncrement: preDeal.maxCouponCount > effectiveCount ? () => setState(() => _requestedCouponCount = effectiveCount + 1) : null,
            ),
            const SizedBox(height: 10),
            _ServiceCouponProductCard(products: preDeal.products, remarkController: _remarkController),
            const SizedBox(height: 10),
            _ServiceCouponAmountCard(preDeal: preDeal),
            const SizedBox(height: 10),
            const _ServiceCouponPaymentCard(),
          ],
        ),
      ),
    );
  }

  int _effectiveCouponCount(ServiceCouponPreDealData preDeal) {
    if (preDeal.maxCouponCount <= 0) return 0;
    if (_requestedCouponCount < 1) return 1;
    if (_requestedCouponCount > preDeal.maxCouponCount) return preDeal.maxCouponCount;
    return _requestedCouponCount;
  }

  int? _resolveSubmitAddressId(ServiceCouponPreDealData preDeal) {
    if (preDeal.dontShowAddress) {
      return _selectedAddressId ?? preDeal.shipAddress?.id ?? 0;
    }
    final addressId = _selectedAddressId ?? preDeal.shipAddress?.id;
    return addressId != null && addressId > 0 ? addressId : null;
  }

  Future<void> _showAddressPicker(ServiceCouponOrderAddress? currentAddress) async {
    List<MemberAddress> addresses;
    try {
      addresses = await ref.read(memberAddressesProvider.future);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('地址加载失败，请稍后重试')));
      }
      return;
    }
    if (!mounted) return;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('暂无可用收货地址')));
      return;
    }

    final selected = await showModalBottomSheet<MemberAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => _AddressPickerSheet(addresses: addresses, selectedId: _selectedAddressId ?? currentAddress?.id),
    );
    if (!mounted || selected == null) return;

    final addressId = int.tryParse(selected.id ?? '');
    if (addressId == null || addressId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('所选地址无效，请重新选择')));
      return;
    }
    setState(() => _selectedAddressId = addressId);
  }

  Future<void> _submit(ServiceCouponPreDealData preDeal, int effectiveCount) async {
    final addressId = _resolveSubmitAddressId(preDeal);
    if (widget.serviceCouponId <= 0 || addressId == null || effectiveCount <= 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final response = await ref
        .read(serviceCouponOrderControllerProvider)
        .submit(
          serviceCouponId: widget.serviceCouponId,
          count: effectiveCount,
          addressId: addressId,
          remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!response.success || response.data == null || response.data!.orderId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.success ? '订单提交失败，请稍后重试' : response.message)));
      return;
    }

    final result = response.data!;
    final orderId = result.orderId.toString();
    context.push(
      RouteNames.mallPaymentSuccess,
      extra: MallPaymentSuccessData(
        orderId: orderId,
        orderNo: orderId,
        transactionNo: 'WX${DateTime.now().millisecondsSinceEpoch}',
        amountCents: _toCents(result.payableAmount),
        discountCents: _toCents(preDeal.totalDiscount),
      ),
    );
  }
}

class _ServiceCouponAddressCard extends StatelessWidget {
  const _ServiceCouponAddressCard({required this.address, required this.onEditAddress});

  final ServiceCouponOrderAddress? address;
  final VoidCallback onEditAddress;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.id > 0;
    return _Panel(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/points/confirm_order_location.png', width: 18, height: 20),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  hasAddress ? address!.regionText : '请选择收货地址',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF8E8E93)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hasAddress ? address!.address : '暂无默认地址',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onEditAddress,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Text('修改地址>', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.serviceTabActive)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasAddress ? '${address!.name}  ${address!.displayPhone}' : '请选择地址后提交订单',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF1F2024)),
          ),
        ],
      ),
    );
  }
}

class _ServiceCouponQuantityCard extends StatelessWidget {
  const _ServiceCouponQuantityCard({required this.count, required this.maxCount, required this.onDecrement, required this.onIncrement});

  final int count;
  final int maxCount;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '服务券数量（最多${maxCount < 0 ? 0 : maxCount}张）',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF1F2024)),
            ),
          ),
          const SizedBox(width: 12),
          _ServiceCouponStepper(count: count, onDecrement: onDecrement, onIncrement: onIncrement),
        ],
      ),
    );
  }
}

class _ServiceCouponStepper extends StatelessWidget {
  const _ServiceCouponStepper({required this.count, required this.onDecrement, required this.onIncrement});

  final int count;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB7D7FF), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StepperTapArea(icon: Icons.remove, onTap: onDecrement, semanticLabel: '减少服务券数量'),
          ),
          const VerticalDivider(width: 1.5, thickness: 1.5, color: Color(0xFFB7D7FF)),
          SizedBox(
            width: 37,
            child: Center(
              child: Text('$count', style: const TextStyle(fontSize: 18, height: 1, color: Color(0xFF1F2024))),
            ),
          ),
          const VerticalDivider(width: 1.5, thickness: 1.5, color: Color(0xFFB7D7FF)),
          Expanded(
            child: _StepperTapArea(icon: Icons.add, onTap: onIncrement, semanticLabel: '增加服务券数量'),
          ),
        ],
      ),
    );
  }
}

class _StepperTapArea extends StatelessWidget {
  const _StepperTapArea({required this.icon, required this.onTap, required this.semanticLabel});

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(height: 34, child: Icon(icon, size: 20, color: enabled ? const Color(0xFF1F2024) : const Color(0xFFC6C6C8))),
      ),
    );
  }
}

class _ServiceCouponProductCard extends StatelessWidget {
  const _ServiceCouponProductCard({required this.products, required this.remarkController});

  final List<ServiceCouponOrderProduct> products;
  final TextEditingController remarkController;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Column(
        children: [
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text('暂无商品信息', style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
            )
          else
            for (var index = 0; index < products.length; index++) ...[
              _ServiceCouponProductRow(product: products[index]),
              if (index != products.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFE3E8F0)),
                ),
            ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE3E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('留言备注', style: TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF1F2024))),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: remarkController,
                  maxLength: 100,
                  textAlign: TextAlign.right,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF1F2024)),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '请填写备注信息 >',
                    hintStyle: TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF8E8E93)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCouponProductRow extends StatelessWidget {
  const _ServiceCouponProductRow({required this.product});

  final ServiceCouponOrderProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: AppNetworkImage(url: product.imageUrl ?? '', width: 70, height: 70, fit: BoxFit.cover, memCacheWidth: 140, memCacheHeight: 140),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
                ),
                if (product.displaySpec.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    product.displaySpec,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.3, color: Color(0xFF8E8E93)),
                  ),
                ],
                if (product.warning != null && product.warning!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.warning!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.serviceButtonRed),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('可兑换数量', style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF8E8E93))),
            const SizedBox(height: 5),
            Text(
              '${product.quantity < 0 ? 0 : product.quantity}张',
              style: const TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w600, color: AppColors.serviceButtonRed),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceCouponAmountCard extends StatelessWidget {
  const _ServiceCouponAmountCard({required this.preDeal});

  final ServiceCouponPreDealData preDeal;

  @override
  Widget build(BuildContext context) {
    final productTotal = preDeal.stores.fold(Decimal.zero, (sum, item) => sum + item.orderAmount);
    return _Panel(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: Column(
        children: [
          _AmountRow(label: '商品总价', value: _money(productTotal), valueColor: AppColors.serviceButtonRed),
          const SizedBox(height: 11),
          _AmountRow(label: '运费', value: _money(preDeal.shipFee)),
          const SizedBox(height: 11),
          _AmountRow(label: '优惠金额', value: '-${_money(preDeal.totalDiscount)}', valueColor: AppColors.serviceButtonRed),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFE3E8F0)),
          const SizedBox(height: 14),
          _AmountRow(label: '合计金额', value: _money(preDeal.totalAmount), valueColor: AppColors.serviceButtonRed, valueSize: 18),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.valueColor = const Color(0xFF1F2024), this.valueSize = 16});

  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: valueSize > 16 ? 27 : 24,
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF1F2024))),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: valueSize, height: 1.4, fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCouponPaymentCard extends StatelessWidget {
  const _ServiceCouponPaymentCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Image.asset('assets/images/order/confirm-order-wechat.png', width: 26, height: 26),
          const SizedBox(width: 10),
          const Text(
            '微信支付',
            style: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
          ),
          const Spacer(),
          Image.asset('assets/images/order/confirm-order-selected.png', width: 20, height: 20),
        ],
      ),
    );
  }
}

class _ServiceCouponOrderBottomBar extends StatelessWidget {
  const _ServiceCouponOrderBottomBar({required this.amount, required this.discount, required this.enabled, required this.submitting, required this.onSubmit});

  final Decimal amount;
  final Decimal discount;
  final bool enabled;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 12, MediaQuery.paddingOf(context).bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '合计：',
                          style: TextStyle(fontSize: 14, color: Color(0xFF1F2024)),
                        ),
                        TextSpan(
                          text: _money(amount),
                          style: const TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w500, color: Color(0xFFFE273D)),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text('共减免${_money(discount)}', style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.serviceButtonRed)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 156,
            height: 47,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: enabled ? const [AppColors.serviceCtaGradStart, AppColors.serviceTabActive] : const [Color(0xFFB9C1D4), Color(0xFFD0D5E0)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: TextButton(
                onPressed: enabled ? onSubmit : null,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: const StadiumBorder()),
                child: Text(
                  submitting ? '提交中...' : '提交订单',
                  style: const TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet({required this.addresses, required this.selectedId});

  final List<MemberAddress> addresses;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: (MediaQuery.sizeOf(context).height * 0.58).clamp(360.0, 560.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
              child: Text(
                '选择收货地址',
                style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF1F2024)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final id = int.tryParse(address.id ?? '');
                  final selected = id != null && id == selectedId;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(address),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: selected ? AppColors.serviceTabActive : const Color(0xFFE3E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${address.name}  ${address.phone}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: Color(0xFF1F2024)),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  address.fullAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF6F747B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            selected ? Icons.check_circle : Icons.circle_outlined,
                            size: 22,
                            color: selected ? AppColors.serviceTabActive : const Color(0xFFB7BDC7),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.height, this.padding = const EdgeInsets.all(10)});

  final Widget child;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: child,
    );
  }
}

String _money(Decimal value) => '¥${value.toStringAsFixed(2)}';

int _toCents(Decimal value) => (value * Decimal.fromInt(100)).round().toBigInt().toInt();
