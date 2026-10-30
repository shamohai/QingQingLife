import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/offline_activity_detail_model.dart';
import '../../domain/models/service_booking_success_data.dart';
import '../providers/offline_activity_signup_provider.dart';
import '../providers/service_provider.dart';
import 'service_booking_success_page.dart';

/// 挚友会独立报名页，不复用服务预约表单。
///
/// 如果传入 [detail] 且 [detail.mySignupInfo] 不为空，则展示已有报名信息（回显模式）；
/// 否则为空表单（新报名模式）。
class ServiceFriendBookingFormPage extends ConsumerStatefulWidget {
  final OfflineActivityDetail detail;

  const ServiceFriendBookingFormPage({super.key, required this.detail});

  @override
  ConsumerState<ServiceFriendBookingFormPage> createState() => _ServiceFriendBookingFormPageState();
}

class _ServiceFriendBookingFormPageState extends ConsumerState<ServiceFriendBookingFormPage> {
  //late final TextEditingController _countController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _friendCountController;

  bool _bringFriend = false;
  bool _submitting = false;
  bool _isAlreadyReserved = false;

  @override
  void initState() {
    super.initState();
    // _countController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _friendCountController = TextEditingController();

    _populateFromSignupInfo();
  }

  void _populateFromSignupInfo() {
    final signupInfo = widget.detail.mySignupInfo;
    if (signupInfo == null) return;
    // _countController.text = signupInfo.signupUserCount.toString();
    _nameController.text = signupInfo.username;
    _phoneController.text = signupInfo.phone;
    final friendCount = signupInfo.signupUserCount - 1;
    if (friendCount > 0) {
      _bringFriend = true;
      _friendCountController.text = '$friendCount人';
    }
  }

  @override
  void dispose() {
    // _countController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _friendCountController.dispose();
    super.dispose();
  }

  Widget _buildHeroImage() {
    final postUrl = widget.detail.postUrl;
    if (postUrl.isNotEmpty) {
      return AppNetworkImage(
        url: postUrl,
        fit: BoxFit.cover,
        placeholder: Container(color: AppColors.surfaceVariant),
        errorWidget: Container(color: AppColors.surfaceVariant),
      );
    }
    return Container(color: AppColors.surfaceVariant);
  }

  // ─── 验证 ────────────────────────────────────────────────────────────

  static final RegExp _phoneRegex = RegExp(r'^1\d{10}$');

  String? _validateName() {
    final v = _nameController.text.trim();
    if (v.isEmpty) return '请输入联系人姓名';
    return null;
  }

  String? _validatePhone() {
    final v = _phoneController.text.trim();
    if (v.isEmpty) return '请输入联系电话';
    if (!_phoneRegex.hasMatch(v)) return '请输入正确的联系电话';
    return null;
  }

  //String? _validateCount() {
  //  final v = _countController.text.trim();
  //  if (v.isEmpty) return '请输入报名人数';
  //  final n = int.tryParse(v);
  //  if (n == null || n < 1 || n > 999) return '请输入正确的报名人数';
  //  return null;
  //}

  String? _validateFriendCount() {
    final v = _friendCountController.text.trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    if (n == null || n < 0 || n > 999) return '请输入正确的亲友人数';
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleSubmit() async {
    // 检查 activityId 是否为空
    if (widget.detail.activityId.isEmpty) {
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
    //final countError = _validateCount();
    //if (countError != null) {
    //  _showError(countError);
    //  return;
    //}
    final friendCountError = _validateFriendCount();
    if (friendCountError != null) {
      _showError(friendCountError);
      return;
    }

    final maxSignupCount = widget.detail.maxSignupCount;
    //final count = int.tryParse(_countController.text.trim()) ?? 0;
    final friendCountNum = int.tryParse(_friendCountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (maxSignupCount == 0) {
      await _showLimitDialog('暂无挚友会权益，无法报名', showBuyWineServiceButton: false);
      return;
    } else if (maxSignupCount == 1) {
      if (_bringFriend || friendCountNum > 0) {
        await _showLimitDialog('该活动仅限本人参加，不可携带亲友', showBuyWineServiceButton: false);
        return;
      }
      //if (count > 1) {
      //  await _showLimitDialog('该活动仅限本人参加，报名人数不能超过 1 人');
      //  return;
      //}
    } else {
      if (_bringFriend && friendCountNum > maxSignupCount - 1) {
        await _showLimitDialog('携带亲友人数已经达到上限\n请参与购酒享服务活动', showBuyWineServiceButton: true);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _submitting = true);

    final params = <String, dynamic>{
      'activityid': widget.detail.activityId,
      'username': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'idno': '',
      'remark': '',
      'signupusercount': friendCountNum + 1, // 报名人数 = 本人 + 亲友人数
    };

    try {
      await ref.read(signupOfflineActivityProvider(params).future);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _isAlreadyReserved = true;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceBookingSuccessPage(
            data: ServiceBookingSuccessData(source: ServiceBookingSuccessSource.friendActivity, sourceId: widget.detail.activityId),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('网络异常，请重试'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _showLimitDialog(String message, {bool showBuyWineServiceButton = false}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, size: 24, color: Color(0xFF333333)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // 提示文案
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black, height: 1.4),
                ),
                const SizedBox(height: 32),
                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (showBuyWineServiceButton) {
                        ref.read(selectedTabProvider.notifier).update('goujiu');
                        context.go(RouteNames.service);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.serviceTabActive,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                      elevation: 0,
                    ),
                    child: Text(showBuyWineServiceButton ? '前往购酒享服务' : '我知道了', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.servicePageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 14, right: 14),
          icon: Image.asset('assets/images/service/icon_back_project_detail.png', width: 24, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.detail.title, style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: AspectRatio(aspectRatio: 412 / 180, child: _buildHeroImage()),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: const [BoxShadow(color: Color(0xFFE6E8E9), blurRadius: 7, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 17, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //_FriendField(
                      //  label: '报名人数',
                      //  icon: Icons.groups_outlined,
                      //  child: _input(_countController, '请输入报名人数', keyboardType: TextInputType.number),
                      //),
                      _FriendField(label: '联系人', icon: Icons.person_outline, child: _input(_nameController, '请输入联系人姓名')),
                      _FriendField(
                        label: '联系电话',
                        icon: Icons.phone_in_talk_outlined,
                        child: _input(_phoneController, '请输入联系人电话', keyboardType: TextInputType.phone),
                      ),
                      const Text(
                        '是否携带亲友',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.serviceTabActive),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Choice(selected: _bringFriend, label: '是', onTap: _isAlreadyReserved ? null : () => setState(() => _bringFriend = true)),
                          const SizedBox(width: 54),
                          _Choice(
                            selected: !_bringFriend,
                            label: '否',
                            onTap: _isAlreadyReserved
                                ? null
                                : () => setState(() {
                                    _bringFriend = false;
                                    _friendCountController.clear();
                                  }),
                          ),
                        ],
                      ),
                      if (_bringFriend) ...[
                        const SizedBox(height: 16),
                        _FriendField(
                          label: '亲友人数',
                          icon: Icons.people_outline,
                          child: _input(_friendCountController, '0人', keyboardType: TextInputType.number),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 16),
          child: SizedBox(
            height: 51,
            child: ElevatedButton(
              onPressed: (_submitting || _isAlreadyReserved) ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAlreadyReserved ? AppColors.serviceButtonDisabled : AppColors.serviceTabActive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _isAlreadyReserved ? '已报名' : '提交报名',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _isAlreadyReserved ? AppColors.serviceButtonDisabledText : Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isAlreadyReserved,
      inputFormatters: keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)] : null,
      style: TextStyle(fontSize: 16, color: _isAlreadyReserved ? const Color(0xFF333333) : Colors.black),
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: _isAlreadyReserved,
        fillColor: _isAlreadyReserved ? const Color(0xFFF5F5F5) : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _FriendField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _FriendField({required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.serviceTabActive),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.servicePageBackground, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(icon, size: 25, color: AppColors.serviceTabActive),
                const SizedBox(width: 12),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback? onTap;

  const _Choice({required this.selected, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, size: 24, color: selected ? const Color(0xFF0088FF) : const Color(0xFF8E8E93)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 16, color: selected ? Colors.black : const Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}
