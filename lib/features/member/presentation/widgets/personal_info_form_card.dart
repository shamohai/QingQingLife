import 'package:flutter/material.dart';

/// 个人信息表单卡片（个人信息页）
///
/// 结构（设计稿）：昵称输入框 / 性别单选 / 生日选择器 / 修改资料按钮。
///
/// 数据说明：
/// - 昵称初始值由页面从 userProfileProvider 注入；
/// - 性别、生日使用表单状态，并在提交时转换为接口要求的枚举和值。
class PersonalInfoFormCard extends StatefulWidget {
  /// 昵称初始值（来源：userProfileProvider）
  final String initialNickname;
  final Future<String?> Function({required String nickname, required int gender, required DateTime birthday})? onSave;

  const PersonalInfoFormCard({super.key, required this.initialNickname, this.onSave});

  @override
  State<PersonalInfoFormCard> createState() => _PersonalInfoFormCardState();
}

class _PersonalInfoFormCardState extends State<PersonalInfoFormCard> {
  // TODO(Mock): 性别 / 生日 —— 后端暂无对应字段，先以本地状态还原 UI
  String _gender = '男';
  DateTime _birthday = DateTime(2026, 10, 10);
  bool _saving = false;

  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 54, 14, 24),
      decoration: BoxDecoration(color: _Palette.cardBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldLabel('昵称'),
          const SizedBox(height: 11.5),
          _buildNicknameField(),
          const SizedBox(height: 17),
          const _FieldLabel('性别'),
          const SizedBox(height: 13.5),
          _buildGenderRow(),
          const SizedBox(height: 18.5),
          const _FieldLabel('生日'),
          const SizedBox(height: 12),
          _buildBirthdayField(),
          const SizedBox(height: 26),
          _buildSaveButton(),
        ],
      ),
    );
  }

  /// 昵称输入框：字段图标 + 可编辑文本
  Widget _buildNicknameField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.person_outline, size: 16, color: _Palette.icon),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _nicknameController,
              maxLines: 1,
              style: const TextStyle(fontSize: 13, color: _Palette.inputText, height: 1.2),
              cursorColor: _Palette.label,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '请输入昵称',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9AA9C0)),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  /// 性别单选：男 / 女
  Widget _buildGenderRow() {
    return Row(
      children: [
        _GenderOption(label: '男', selected: _gender == '男', onTap: () => setState(() => _gender = '男')),
        const SizedBox(width: 45),
        _GenderOption(label: '女', selected: _gender == '女', onTap: () => setState(() => _gender = '女')),
      ],
    );
  }

  /// 生日选择框：点击弹出日期选择器
  Widget _buildBirthdayField() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickBirthday,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.calendar_today_outlined, size: 16, color: _Palette.icon),
            const SizedBox(width: 9),
            Expanded(
              child: Text(_formatDate(_birthday), style: const TextStyle(fontSize: 13, color: _Palette.dateText, height: 1.2)),
            ),
            const Icon(Icons.expand_more, size: 20, color: _Palette.chevron),
            const SizedBox(width: 35),
          ],
        ),
      ),
    );
  }

  /// 「修改资料」按钮：胶囊渐变（设计稿 #23418A → #2F57BA）
  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _saving ? null : _onSave,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_Palette.buttonStart, _Palette.buttonEnd]),
          borderRadius: BorderRadius.circular(22),
        ),
        child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text(
                '修改资料',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
              ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(context: context, initialDate: _birthday, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null && mounted) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _onSave() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showMessage('请输入昵称');
      return;
    }
    final onSave = widget.onSave;
    if (onSave == null) return;
    setState(() => _saving = true);
    try {
      final message = await onSave(nickname: nickname, gender: _gender == '男' ? 1 : 2, birthday: _birthday);
      if (mounted && message != null) _showMessage(message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}

/// 表单字段标签（设计稿：14 / w500 / #27458D）
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _Palette.label, height: 1.2),
    );
  }
}

/// 性别单选项（圆形勾选 + 文字）
class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? _Palette.radioOn : null,
              border: selected ? null : Border.all(color: _Palette.radioOff, width: 1.5),
            ),
            child: selected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
          ),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 13, color: selected ? _Palette.genderTextOn : _Palette.genderTextOff, height: 1.2)),
        ],
      ),
    );
  }
}

/// 个人信息页局部色板（来源：设计稿采样；项目 AppColors 暂无对应 Token）
abstract final class _Palette {
  static const Color cardBg = Color(0xFFDFEBFF);
  static const Color fieldBg = Color(0xFFD5E2F8);
  static const Color label = Color(0xFF27458D);
  static const Color inputText = Color(0xFF1B273C);
  static const Color dateText = Color(0xFF222E42);
  static const Color icon = Color(0xFF22418A);
  static const Color radioOn = Color(0xFF0686FF);
  static const Color radioOff = Color(0xFF9BA7BE);
  static const Color genderTextOn = Color(0xFF293549);
  static const Color genderTextOff = Color(0xFF8B97AF);
  static const Color chevron = Color(0xFF8591A9);
  static const Color buttonStart = Color(0xFF23418A);
  static const Color buttonEnd = Color(0xFF2F57BA);
}
