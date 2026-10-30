import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/service_booking_success_data.dart';
import '../providers/offline_activity_signup_provider.dart';
import '../widgets/booking_form_field.dart';

/// 活动报名填写信息页面
///
/// 路由: /service/activity/:id/book
/// 进入方式: 从活动详情页点击「立即报名」按钮跳转
///
/// 设计稿来源: 蓝湖 "活动报名-填写信息"
class ServiceActivityBookingFormPage extends ConsumerStatefulWidget {
  final String activityId;
  final String title;
  final String heroAsset;

  const ServiceActivityBookingFormPage({super.key, required this.activityId, required this.title, required this.heroAsset});

  @override
  ConsumerState<ServiceActivityBookingFormPage> createState() => _ServiceActivityBookingFormPageState();
}

class _ServiceActivityBookingFormPageState extends ConsumerState<ServiceActivityBookingFormPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _partyCtrl;
  late final TextEditingController _notesCtrl;

  bool _isSubmitting = false;
  bool _isAlreadyReserved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _idCtrl = TextEditingController();
    _partyCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _idCtrl.dispose();
    _partyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── 验证 ────────────────────────────────────────────────────────────

  static final RegExp _phoneRegex = RegExp(r'^1\d{10}$');
  static final RegExp _idCardRegex = RegExp(r'^\d{17}[\dXx]$');

  String? _validateName() {
    final v = _nameCtrl.text.trim();
    if (v.isEmpty) return '请输入联系人姓名';
    return null;
  }

  String? _validatePhone() {
    final v = _phoneCtrl.text.trim();
    if (v.isEmpty) return '请输入联系电话';
    if (!_phoneRegex.hasMatch(v)) return '请输入正确的联系电话';
    return null;
  }

  String? _validateIdCard() {
    final v = _idCtrl.text.trim();
    if (v.isEmpty) return null;
    if (!_idCardRegex.hasMatch(v.toUpperCase())) return '请输入正确的身份证号码';
    return null;
  }

  String? _validatePartySize() {
    final v = _partyCtrl.text.trim();
    if (v.isEmpty) return '请输入报名人数';
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 999) return '报名人数必须为 1~999 的整数';
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleSubmit() async {
    // 检查 activityId 是否为空
    if (widget.activityId.isEmpty) {
      _showError('活动 ID 为空，无法报名');
      return;
    }

    final nameError = _validateName();
    if (nameError != null) {
      _showError(nameError);
      return;
    }
    final phoneError = _validatePhone();
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }
    final idError = _validateIdCard();
    if (idError != null) {
      _showError(idError);
      return;
    }
    final partyError = _validatePartySize();
    if (partyError != null) {
      _showError(partyError);
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    final params = <String, dynamic>{
      'activityid': widget.activityId,
      'username': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'idno': _idCtrl.text.trim(),
      'remark': _notesCtrl.text.trim(),
      'signupusercount': int.tryParse(_partyCtrl.text.trim()) ?? 1,
    };

    try {
      await ref.read(signupOfflineActivityProvider(params).future);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isAlreadyReserved = true;
      });
      context.go(
        RouteNames.serviceBookingSuccess,
        extra: ServiceBookingSuccessData(
          source: ServiceBookingSuccessSource.activity,
          sourceId: widget.activityId,
          sourceTitle: widget.title,
          recordTab: 'activity',
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('网络异常，请稍后重试'), behavior: SnackBarBehavior.floating));
    }
  }

  // ─── UI helpers ─────────────────────────────────────────────────────────

  Widget _buildTextField(TextEditingController ctrl, {TextInputType? keyboardType, int? maxLength, String? hintText}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLength: maxLength,
      enabled: !_isAlreadyReserved,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(maxLength ?? 11)]
          : keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(maxLength ?? 3)]
          : [],
      style: TextStyle(fontSize: 16, color: _isAlreadyReserved ? const Color(0xFF333333) : Colors.black),
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText ?? '',
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
        contentPadding: EdgeInsets.zero,
        filled: _isAlreadyReserved,
        fillColor: _isAlreadyReserved ? const Color(0xFFF5F5F5) : null,
      ),
    );
  }

  Widget _buildHeroImage() {
    // heroAsset 可能是网络 URL，也可能是本地 asset（兼容旧 mock 路由）
    final url = widget.heroAsset;
    if (url.startsWith('http')) {
      return AppNetworkImage(
        url: url,
        fit: BoxFit.cover,
        placeholder: Container(color: AppColors.surfaceVariant),
        errorWidget: Container(color: AppColors.surfaceVariant),
      );
    }
    return Image.asset(url, fit: BoxFit.cover);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 52,
      leading: IconButton(
        padding: const EdgeInsets.only(left: 14, right: 14),
        icon: Image.asset('assets/images/service/activity_detail_back.png', width: 24, height: 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.title, style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Section 1: Banner（412:180 比例，两侧 14dp padding，圆角 md）
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                        child: AspectRatio(aspectRatio: 412 / 180, child: _buildHeroImage()),
                      ),
                    ),
                    // Section 2: 表单卡片（向上偏移 50dp 与 Banner 重叠）
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                            boxShadow: const [BoxShadow(color: Color(0xFFE6E8E9), blurRadius: 7, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Field 1: 联系人
                              BookingFormField(
                                label: '联系人',
                                imageAsset: 'assets/images/service/service_booking_name.png',
                                valueWidget: _buildTextField(_nameCtrl, maxLength: 30, hintText: '请输入联系人姓名'),
                              ),
                              // Field 2: 联系电话
                              BookingFormField(
                                label: '联系电话',
                                imageAsset: 'assets/images/service/service_booking_phone.png',
                                valueWidget: _buildTextField(_phoneCtrl, keyboardType: TextInputType.phone, maxLength: 11, hintText: '请输入联系人电话'),
                              ),
                              // Field 3: 身份证号码
                              BookingFormField(
                                label: '身份证号码',
                                imageAsset: 'assets/images/service/service_booking_idcard.png',
                                valueWidget: _buildTextField(_idCtrl, maxLength: 18, hintText: '请输入身份证号码'),
                              ),
                              // Field 4: 报名人数
                              BookingFormField(
                                label: '报名人数',
                                imageAsset: 'assets/images/service/service_booking_count.png',
                                valueWidget: _buildTextField(_partyCtrl, keyboardType: TextInputType.number, maxLength: 3, hintText: '请输入报名人数'),
                              ),
                              // Field 5: 备注（多行）
                              const Text(
                                '备注',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 140,
                                decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(AppRadius.sm)),
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _notesCtrl,
                                  maxLines: 5,
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: '请输入备注信息',
                                    hintStyle: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                ),
                              ),
                              // 底部留出按钮空间
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ), // 闭合 Transform.translate
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 固定底部提交按钮
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(30, AppSpacing.md, 30, AppSpacing.lg),
          child: GestureDetector(
            onTap: (_isSubmitting || _isAlreadyReserved) ? null : _handleSubmit,
            child: Container(
              width: double.infinity,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: _isAlreadyReserved
                    ? null
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                      ),
                color: _isAlreadyReserved ? AppColors.serviceButtonDisabled : null,
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isAlreadyReserved ? '已报名' : '提交报名',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _isAlreadyReserved ? AppColors.serviceButtonDisabledText : Colors.white,
                          height: 1.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
