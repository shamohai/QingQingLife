import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/service_coupon_model.dart';
import '../providers/service_coupon_transfer_provider.dart';

Future<ServiceCouponTransferResult?> runServiceCouponTransferFlow({
  required BuildContext context,
  required WidgetRef ref,
  required ServiceCouponInfo coupon,
}) async {
  final count = await showServiceCouponTransferDialog(context: context, maxCount: coupon.num);
  if (count == null || !context.mounted) return null;

  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    ),
  );

  final result = await ref.read(serviceCouponTransferProvider).transfer(coupon: coupon, count: count);
  if (navigator.mounted) navigator.pop();
  if (!context.mounted) return result;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(result.message), behavior: SnackBarBehavior.floating));
  return result;
}

Future<ServiceCouponTransferResult?> runServiceCouponCancelTransferFlow({
  required BuildContext context,
  required WidgetRef ref,
  required ServiceCouponInfo coupon,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    ),
  );

  final result = await ref.read(serviceCouponTransferProvider).revoke(coupon: coupon);
  if (navigator.mounted) navigator.pop();
  if (!context.mounted) return result;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(result.message), behavior: SnackBarBehavior.floating));
  return result;
}

Future<int?> showServiceCouponTransferDialog({required BuildContext context, required int maxCount}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ServiceCouponTransferDialog(maxCount: maxCount),
  );
}

class _ServiceCouponTransferDialog extends StatefulWidget {
  final int maxCount;

  const _ServiceCouponTransferDialog({required this.maxCount});

  @override
  State<_ServiceCouponTransferDialog> createState() => _ServiceCouponTransferDialogState();
}

class _ServiceCouponTransferDialogState extends State<_ServiceCouponTransferDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: Text(
                '可转赠数量：${widget.maxCount}张',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C), height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _handleCountChanged,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  errorText: _errorText,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF2E6EB5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '取消',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF5F6368)),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  Expanded(
                    child: TextButton(
                      onPressed: _confirm,
                      child: const Text(
                        '确认',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E64B5)),
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

  void _handleCountChanged(String value) {
    final count = int.tryParse(value) ?? 0;
    if (count > widget.maxCount) {
      _setCount(widget.maxCount);
      setState(() => _errorText = _maxCountMessage);
      return;
    }
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  void _setCount(int count) {
    final text = count.toString();
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String get _maxCountMessage => '最多可转账${widget.maxCount}张';

  void _confirm() {
    final count = int.tryParse(_controller.text) ?? 0;
    if (count <= 0) {
      setState(() => _errorText = '请输入正确的转赠数量');
      return;
    }
    if (count > widget.maxCount) {
      _setCount(widget.maxCount);
      setState(() => _errorText = _maxCountMessage);
      return;
    }
    Navigator.of(context).pop(count);
  }
}
