import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/models/offline_activity_detail_model.dart';

/// 挚友会独立报名页，不复用服务预约表单。
///
/// 如果传入 [detail] 且 [detail.mySignupInfo] 不为空，则展示已有报名信息（回显模式）；
/// 否则为空表单（新报名模式）。
/// 头图优先从 [detail.postUrl] 获取；若无 detail 则回退到 [heroAsset]（兼容旧 mock 路由）。
class ServiceFriendBookingFormPage extends StatefulWidget {
  final String title;
  final String? heroAsset; // 兼容旧 mock 路由，优先使用 detail.postUrl
  final OfflineActivityDetail? detail;

  const ServiceFriendBookingFormPage({super.key, required this.title, this.heroAsset, this.detail});

  @override
  State<ServiceFriendBookingFormPage> createState() => _ServiceFriendBookingFormPageState();
}

class _ServiceFriendBookingFormPageState extends State<ServiceFriendBookingFormPage> {
  late final TextEditingController _countController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _friendCountController;

  bool _bringFriend = false; // 默认不携带亲友
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _friendCountController = TextEditingController(); // 默认空，不携带亲友时隐藏

    // 如果有已报名信息，回显填充表单
    _populateFromSignupInfo();
  }

  void _populateFromSignupInfo() {
    final signupInfo = widget.detail?.mySignupInfo;
    if (signupInfo == null) return;

    // 回显报名人数（默认 1 人，即本人）
    _countController.text = signupInfo.signupUserCount.toString();
    // 回显联系人姓名
    _nameController.text = signupInfo.username;
    // 回显联系电话
    _phoneController.text = signupInfo.phone;
    // 回显亲友人数：signupusercount - 1（总报名人数减去本人）
    final friendCount = signupInfo.signupUserCount - 1;
    if (friendCount > 0) {
      _bringFriend = true;
      _friendCountController.text = '${friendCount}人';
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _friendCountController.dispose();
    super.dispose();
  }

  Widget _buildHeroImage() {
    final postUrl = widget.detail?.postUrl;
    if (postUrl != null && postUrl.isNotEmpty) {
      return AppNetworkImage(
        url: postUrl,
        fit: BoxFit.cover,
        placeholder: Container(color: AppColors.surfaceVariant),
        errorWidget: Container(color: AppColors.surfaceVariant),
      );
    }
    if (widget.heroAsset != null && widget.heroAsset!.isNotEmpty) {
      return Image.asset(widget.heroAsset!, fit: BoxFit.cover);
    }
    return Container(color: AppColors.surfaceVariant);
  }

  Future<void> _submit() async {
    if (_countController.text.trim().isEmpty || _nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完善报名信息')));
      return;
    }

    final maxSignupCount = widget.detail?.maxSignupCount ?? 0;
    final count = int.tryParse(_countController.text.trim()) ?? 0;
    final friendCount = int.tryParse(_friendCountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final totalCount = count + friendCount;

    // 根据 maxSignupCount 校验
    if (maxSignupCount == 0) {
      await _showLimitDialog('暂无挚友会权益，无法报名');
      return;
    }

    if (maxSignupCount == 1) {
      // 仅自己参加，不能携带亲友
      if (_bringFriend || friendCount > 0) {
        await _showLimitDialog('该活动仅限本人参加，不可携带亲友');
        return;
      }
      if (count > 1) {
        await _showLimitDialog('该活动仅限本人参加，报名人数不能超过 1 人');
        return;
      }
    } else {
      // maxSignupCount > 1，可以携带亲友，总人数不能超过 maxSignupCount
      if (totalCount > maxSignupCount) {
        // 如果是因为携带亲友超限，显示特定提示
        if (_bringFriend && friendCount > 0) {
          await _showLimitDialog('携带亲友人数已经达到上限\n请参与购酒享服务活动');
        } else {
          await _showLimitDialog('报名总人数（含本人）不能超过 $maxSignupCount 人');
        }
        return;
      }
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
  }

  Future<void> _showLimitDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: SizedBox(
            height: 207,
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 18,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 30, color: Color(0xFF333333)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 88),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black, height: 1.4),
                    ),
                  ),
                ),
                Positioned(
                  left: 31,
                  right: 31,
                  bottom: 34,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.serviceTabActive,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                        elevation: 0,
                      ),
                      child: const Text('我知道了', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                    ),
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
        title: Text(widget.title, style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
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
                      _FriendField(
                        label: '报名人数',
                        icon: Icons.groups_outlined,
                        child: _input(_countController, '请输入报名人数', keyboardType: TextInputType.number),
                      ),
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
                          _Choice(
                            selected: _bringFriend,
                            label: '是',
                            onTap: () => setState(() {
                              _bringFriend = true;
                            }),
                          ),
                          const SizedBox(width: 54),
                          _Choice(
                            selected: !_bringFriend,
                            label: '否',
                            onTap: () => setState(() {
                              _bringFriend = false;
                              _friendCountController.clear(); // 不携带亲友时清空
                            }),
                          ),
                        ],
                      ),
                      if (_bringFriend) ...[
                        const SizedBox(height: 16),
                        _FriendField(
                          label: '亲友人数',
                          icon: Icons.people_outline,
                          child: _input(_friendCountController, '1人', keyboardType: TextInputType.number),
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
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.serviceTabActive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('提交报名', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
      inputFormatters: keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)] : null,
      style: const TextStyle(fontSize: 16, color: Colors.black),
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
        filled: false,
        fillColor: Colors.transparent,
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
  final VoidCallback onTap;

  const _Choice({required this.selected, required this.label, required this.onTap});

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
