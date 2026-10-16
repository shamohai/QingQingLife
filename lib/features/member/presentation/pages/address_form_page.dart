import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/repositories/member_repository.dart';
import '../providers/member_addresses_provider.dart';

/// 新增 / 编辑收货地址页（/address/add、/address/edit）
///
/// 入口：地址列表页底部「新增收货地址」按钮（新增模式）、地址卡片铅笔按钮（编辑模式）。
/// 结构（设计稿 375×815）：返回栏「新增地址」→ 白色表单卡片（姓名 / 手机号码 /
///   所在地区 / 详细地址 / 设置为默认地址 / 确认提交）→ 底部湖泊背景图。
/// 数据：
/// - 提交调用 MemberRepository.saveAddress（真实接口：POST /api/sys/setuseraddress）；
/// - 省市区为本地 Mock 数据（后端暂无地区数据接口），见 _RegionPickerSheet。
class AddressFormPage extends ConsumerStatefulWidget {
  /// 编辑模式带入的初始地址；为 null 时为新增模式
  final MemberAddress? initial;

  const AddressFormPage({super.key, this.initial});

  @override
  ConsumerState<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends ConsumerState<AddressFormPage> {
  /// 导航栏与卡片间距（设计稿：卡片顶 91.5 - 导航栏底 74）
  static const double _navToCardGap = 17.5;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _detailController;

  /// 省 / 市 / 区（设计稿默认未选择，显示占位文案）
  String? _province;
  String? _city;
  String? _district;

  bool _isDefault = false;
  bool _submitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _detailController = TextEditingController(text: initial?.detail ?? '');
    _province = initial?.province;
    _city = initial?.city;
    _district = initial?.district;
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 湖泊图片底衬白色（图片底边以下为白条，对齐设计稿页面底部）
            const Positioned(top: 504, left: 0, right: 0, bottom: 0, child: ColoredBox(color: Colors.white)),
            Positioned(
              top: 504,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),

            // 前景内容（小屏或键盘弹出时可滚动）
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNav(context),
                  const SizedBox(height: _navToCardGap),
                  Expanded(
                    child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), child: _buildCard()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部返回栏（标题左对齐，与地址列表页一致）
  Widget _buildNav(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 11, right: 1.5),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _isEdit ? '编辑地址' : '新增地址',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  /// 白色表单卡片（设计稿：x12、宽 351、圆角 8，内边距 10 / 17.5 / 8 / 28.5）
  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 17.5, 8, 28.5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldLabel('姓名'),
          const SizedBox(height: 10),
          _buildNameField(),
          const SizedBox(height: 16.5),
          const _FieldLabel('手机号码'),
          const SizedBox(height: 10),
          _buildPhoneField(),
          const SizedBox(height: 16.5),
          const _FieldLabel('所在地区'),
          const SizedBox(height: 10),
          _buildRegionField(),
          const SizedBox(height: 17),
          const _FieldLabel('详细地址'),
          const SizedBox(height: 9.5),
          _buildDetailField(),
          const SizedBox(height: 13.5),
          _buildDefaultRow(),
          const SizedBox(height: 20.5),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  /// 姓名输入框（设计稿：浅灰底 40 高，占位「请输入姓名」）
  Widget _buildNameField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            // 设计稿文字相对输入框中心略偏下 1px，用顶部内边距微调基线
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TextField(
                controller: _nameController,
                maxLines: 1,
                style: const TextStyle(fontSize: 13.5, color: _Palette.inputText, height: 1.2),
                cursorColor: _Palette.label,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '请输入姓名',
                  hintStyle: TextStyle(fontSize: 13.5, color: _Palette.hint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  /// 手机号码输入框（设计稿：占位「请输入手机号码」，仅数字、限 11 位）
  Widget _buildPhoneField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TextField(
                controller: _phoneController,
                maxLines: 1,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                style: const TextStyle(fontSize: 13.5, color: _Palette.inputText, height: 1.2),
                cursorColor: _Palette.label,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '请输入手机号码',
                  hintStyle: TextStyle(fontSize: 13.5, color: _Palette.hint),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  /// 所在地区选择框（设计稿：占位「请选择省、市、区」，右侧下拉箭头）
  Widget _buildRegionField() {
    final hasRegion = _province != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickRegion,
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  hasRegion ? _regionText : '请选择省、市、区',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, color: hasRegion ? _Palette.inputText : _Palette.hint, height: 1.2),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 25, color: _Palette.chevron),
            const SizedBox(width: 8.5),
          ],
        ),
      ),
    );
  }

  /// 详细地址输入框（设计稿：97 高，占位「请输入详细地址 例如小区/单元/楼层等」）
  Widget _buildDetailField() {
    return Container(
      height: 97,
      padding: const EdgeInsets.fromLTRB(10, 14.5, 10, 8),
      decoration: BoxDecoration(color: _Palette.fieldBg, borderRadius: BorderRadius.circular(6)),
      child: Align(
        alignment: Alignment.topLeft,
        child: TextField(
          controller: _detailController,
          minLines: 1,
          maxLines: 4,
          style: const TextStyle(fontSize: 13.5, color: _Palette.inputText, height: 1.2),
          cursorColor: _Palette.label,
          decoration: const InputDecoration(
            isCollapsed: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '请输入详细地址 例如小区/单元/楼层等',
            hintStyle: TextStyle(fontSize: 13.5, color: _Palette.hint),
          ),
        ),
      ),
    );
  }

  /// 「设置为默认地址」行 + iOS 风格开关（设计稿：开关轨道 36×24，距卡片内容右缘 15）
  Widget _buildDefaultRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 设计稿中该行文字基线比常规行更低，向下微调 2px
        Transform.translate(offset: const Offset(0, 2), child: const _FieldLabel('设置为默认地址')),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: _ToggleSwitch(value: _isDefault, onChanged: (value) => setState(() => _isDefault = value)),
        ),
      ],
    );
  }

  /// 「确认提交」按钮（设计稿：x25.5..349.5、胶囊渐变 #1F3573 → #3050AE，与地址列表页按钮一致）
  Widget _buildSubmitButton() {
    return Padding(
      // 设计稿按钮相对卡片左右各留 13.5（卡片内容已留 10/8，这里再补 3.5/5.5）
      padding: const EdgeInsets.only(left: 3.5, right: 5.5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onSubmit,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [_Palette.buttonStart, _Palette.buttonEnd]),
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '确认提交',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  /// 已选地区展示文案（省市区相同时去重，如「北京市 朝阳区」）
  String get _regionText {
    final parts = [_province!, if (_city != null && _city != _province) _city!, ?_district];
    return parts.join(' ');
  }

  /// 打开省市区选择弹层
  Future<void> _pickRegion() async {
    final result = await AppBottomSheet.show<List<String>>(
      context: context,
      isScrollControlled: true,
      child: _RegionPickerSheet(initial: _province == null ? null : [_province!, _city!, _district!]),
    );
    if (result != null && mounted) {
      setState(() {
        _province = result[0];
        _city = result[1];
        _district = result[2];
      });
    }
  }

  /// 「确认提交」：本地校验后调用保存接口，成功后刷新列表并返回
  Future<void> _onSubmit() async {
    if (_submitting) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final detail = _detailController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('请输入姓名');
      return;
    }
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      _showSnackBar('请输入正确的手机号码');
      return;
    }
    if (_province == null || _city == null || _district == null) {
      _showSnackBar('请选择所在地区');
      return;
    }
    if (detail.isEmpty) {
      _showSnackBar('请输入详细地址');
      return;
    }

    setState(() => _submitting = true);
    final response = await ref
        .read(memberRepositoryProvider)
        .saveAddress(
          MemberAddress(
            id: widget.initial?.id,
            name: name,
            phone: phone,
            province: _province!,
            city: _city!,
            district: _district!,
            detail: detail,
            isDefault: _isDefault,
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (response.success) {
      ref.invalidate(memberAddressesProvider);
      _showSnackBar(_isEdit ? '地址修改成功' : '地址添加成功');
      // 常规入口从列表页 push 进入可直接返回；deep link 直达时回退到地址列表
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.address);
      }
    } else {
      _showSnackBar(response.message);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }
}

/// 表单字段标签（设计稿：15 / w500 / #213775）
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    // 设计稿文字基线略低于行盒中心，加 1px 顶距对齐
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _Palette.label, height: 1.2),
      ),
    );
  }
}

/// iOS 风格开关（设计稿：36×24、圆角 12、#D9D9D9 轨道 + 白色圆钮）
///
/// 设计稿只有关闭态；开启态轨道使用功能蓝 #0088FF（与默认地址勾选圆点一致）。
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 24,
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(color: value ? _Palette.toggleOn : _Palette.toggleOff, borderRadius: BorderRadius.circular(12)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

/// 省 / 市 / 区选择弹层（三列联动）
///
/// TODO(Mock): 省市区数据后端暂未提供接口，先用本地少量数据演示联动选择，
/// 接口就绪后改为从服务端获取；当前仅保证 Mock 数据源可用。
class _RegionPickerSheet extends StatefulWidget {
  /// 已选 [省, 市, 区]（编辑模式带入）
  final List<String>? initial;

  const _RegionPickerSheet({this.initial});

  @override
  State<_RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<_RegionPickerSheet> {
  /// TODO(Mock): 本地演示数据（含 Mock 地址使用的甘肃省兰州市七里河区）
  static const Map<String, Map<String, List<String>>> _regions = {
    '甘肃省': {
      '兰州市': ['七里河区', '城关区', '安宁区', '西固区'],
      '天水市': ['秦州区', '麦积区'],
    },
    '北京市': {
      '北京市': ['朝阳区', '海淀区', '东城区', '西城区'],
    },
    '上海市': {
      '上海市': ['浦东新区', '徐汇区', '静安区', '黄浦区'],
    },
    '广东省': {
      '广州市': ['天河区', '越秀区', '海珠区'],
      '深圳市': ['南山区', '福田区', '宝安区'],
    },
    '浙江省': {
      '杭州市': ['西湖区', '拱墅区', '滨江区'],
      '宁波市': ['海曙区', '鄞州区', '江北区'],
    },
    '四川省': {
      '成都市': ['武侯区', '锦江区', '高新区'],
    },
  };

  late String _province;
  late String _city;
  late String _district;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _province = initial != null && _regions.containsKey(initial[0]) ? initial[0] : _regions.keys.first;
    final cities = _regions[_province]!;
    _city = initial != null && cities.containsKey(initial[1]) ? initial[1] : cities.keys.first;
    final districts = cities[_city]!;
    _district = initial != null && districts.contains(initial[2]) ? initial[2] : districts.first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 18, bottom: 12),
            child: Text(
              '选择所在地区',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D1C)),
            ),
          ),
          SizedBox(
            height: 264,
            child: Row(
              children: [
                Expanded(child: _buildColumn(_regions.keys.toList(), _province, _onProvinceChanged)),
                const VerticalDivider(width: 0.5, thickness: 0.5, color: Color(0xFFEFF1F4)),
                Expanded(child: _buildColumn(_regions[_province]!.keys.toList(), _city, _onCityChanged)),
                const VerticalDivider(width: 0.5, thickness: 0.5, color: Color(0xFFEFF1F4)),
                Expanded(child: _buildColumn(_regions[_province]![_city]!, _district, (value) => setState(() => _district = value))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop([_province, _city, _district]),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [_Palette.buttonStart, _Palette.buttonEnd]),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    '确定',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onProvinceChanged(String value) {
    setState(() {
      _province = value;
      _city = _regions[value]!.keys.first;
      _district = _regions[value]![_city]!.first;
    });
  }

  void _onCityChanged(String value) {
    setState(() {
      _city = value;
      _district = _regions[_province]![value]!.first;
    });
  }

  /// 单列选项列表（选中项主题蓝加粗）
  Widget _buildColumn(List<String> options, String selected, ValueChanged<String> onSelect) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option == selected;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(option),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Text(
              option,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 新增 / 编辑收货地址页局部色板（来源：设计稿采样；项目 AppColors 暂无对应 Token）
abstract final class _Palette {
  static const Color label = Color(0xFF213775);
  static const Color hint = Color(0xFF919195);
  static const Color inputText = Color(0xFF1B273C);
  static const Color fieldBg = Color(0xFFF3F5F7);
  static const Color chevron = Color(0xFF939498);
  static const Color toggleOff = Color(0xFFD9D9D9);
  static const Color toggleOn = Color(0xFF0088FF);
  static const Color buttonStart = Color(0xFF1F3573);
  static const Color buttonEnd = Color(0xFF3050AE);
}
