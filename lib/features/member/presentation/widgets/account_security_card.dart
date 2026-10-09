import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/member_repository.dart';
import '../providers/member_addresses_provider.dart';
import '../providers/user_profile_provider.dart';

/// 账号信息卡片（「账号安全」页）
///
/// 展示：UID / 昵称 / 性别 / 出生日期 / 手机号 / 版本号 / 我的地址。
/// 数据来源：UID、昵称、手机号取 userProfileProvider；地址取 memberAddressesProvider；
/// 性别 / 出生日期 / 版本号后端暂未提供字段，使用 TODO(Mock) 占位值做 UI 还原。
class AccountSecurityCard extends ConsumerWidget {
  const AccountSecurityCard({super.key});

  /// TODO(Mock): 性别 —— 后端 MemberInfo 暂无该字段，使用设计稿占位值。
  static const String _mockGender = '男';

  /// TODO(Mock): 出生日期 —— 后端 MemberInfo 暂无该字段，使用设计稿占位值。
  static const String _mockBirthday = '1997-10-01';

  /// TODO(Mock): 版本号 —— 后端暂无该字段（是产品版本编号，非 App 版本号，故不用 PackageInfo），使用设计稿占位值。
  static const String _mockVersion = 'TYD202602';

  static const Color _cardBg = Color(0xFFDFEBFF);
  static const Color _labelColor = Color(0xFF232F43);
  static const Color _valueColor = Color(0xFF8F9BB1);
  static const Color _editIconColor = Color(0xFF8995AC);

  static const TextStyle _labelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _labelColor, height: 1.2);
  static const TextStyle _valueStyle = TextStyle(fontSize: 14, color: _valueColor, height: 1.2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final addressesAsync = ref.watch(memberAddressesProvider);
    final addresses = addressesAsync.hasValue ? addressesAsync.value! : const <MemberAddress>[];
    final address = addresses.isNotEmpty ? addresses.first : null;
    // 省市区与详细地址分两行展示（设计稿为手动换行）
    final addressText = address == null ? '' : '${address.province}${address.city}${address.district}\n${address.detail}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25.5, 36.5, 25.5, 14.5),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildRow(
            label: 'UID',
            value: Text(profileState.memberInfo.id, style: _valueStyle),
          ),
          _buildRow(
            label: '昵称',
            value: Text(profileState.nickname, style: _valueStyle),
          ),
          _buildRow(
            label: '性别',
            value: const Text(_mockGender, style: _valueStyle),
          ),
          _buildRow(
            label: '出生日期',
            value: const Text(_mockBirthday, style: _valueStyle),
          ),
          _buildRow(label: '手机号', value: _buildPhoneValue(profileState.phoneMasked)),
          _buildRow(
            label: '版本号',
            value: const Text(_mockVersion, style: _valueStyle),
          ),
          _buildRow(
            height: 62,
            topPadding: 4,
            label: '我的地址',
            value: Text(addressText, textAlign: TextAlign.right, style: _valueStyle.copyWith(height: 1.43)),
          ),
        ],
      ),
    );
  }

  /// 单行信息（标签居左 / 内容居右）
  ///
  /// [topPadding] 用于对齐设计稿：地址行内容在设计稿中略低于垂直居中位置（约 +2）。
  Widget _buildRow({required String label, required Widget value, double height = 46, double topPadding = 0}) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Row(
          children: [
            Text(label, style: _labelStyle),
            const Spacer(),
            value,
          ],
        ),
      ),
    );
  }

  /// 手机号（掩码）+ 编辑图标
  ///
  /// TODO: 修改绑定手机号流程依赖后端短信/换绑接口，后端暂未提供，待接入后补充。
  Widget _buildPhoneValue(String phoneMasked) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => debugPrint('[AccountSecurityCard] 修改绑定手机号点击'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(phoneMasked, style: _valueStyle),
          const SizedBox(width: 5),
          const Icon(Icons.drive_file_rename_outline, size: 16, color: _editIconColor),
        ],
      ),
    );
  }
}
