import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/member_repository.dart';
import '../providers/member_addresses_provider.dart';
import '../providers/user_profile_provider.dart';

/// 账号信息卡片（「账号安全」页）
///
/// 展示：UID / 昵称 / 性别 / 出生日期 / 手机号 / 版本号 / 我的地址。
/// 数据来源：UID、昵称、手机号、性别、出生日期取 userProfileProvider（getmyprofile）；
/// 地址优先取 getmyprofile 顶层 address，缺失时回退 memberAddressesProvider 的首条地址。
class AccountSecurityCard extends ConsumerWidget {
  const AccountSecurityCard({super.key});

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
    // getmyprofile 的 address 是单行完整地址；收货地址列表则按「省市区 / 详细地址」分两行展示。
    final addressText = profileState.address ?? (address == null ? '' : '${address.province}${address.city}${address.district}\n${address.detail}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25.5, 36.5, 25.5, 14.5),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildRow(
            label: '昵称',
            value: Text(profileState.nickname, style: _valueStyle),
          ),
          _buildRow(
            label: '性别',
            value: Text(profileState.genderText, style: _valueStyle),
          ),
          _buildRow(
            label: '出生日期',
            value: Text(_formatBirthday(profileState.birthday), style: _valueStyle),
          ),
          _buildRow(label: '手机号', value: _buildPhoneValue(profileState.phoneMasked)),
          _buildRow(
            height: 62,
            topPadding: 4,
            label: '我的地址',
            value: Text(addressText, textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis, style: _valueStyle.copyWith(height: 1.43)),
          ),
        ],
      ),
    );
  }

  /// 单行信息（标签居左 / 内容居右，各行内容右边缘严格对齐）
  ///
  /// 说明：内容列必须用 `Expanded + Align(centerRight)`，不能用
  /// `Spacer + Flexible(loose)` —— 后者中 Spacer 与 Flexible 均分剩余空间，
  /// 内容比分配空间窄时，多余空间会留在行尾（mainAxisAlignment.start 的 trailing），
  /// 导致不同长度的内容右边缘参差不齐，看起来"没对齐"。
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
            const SizedBox(width: 24),
            // 内容占满标签右侧的剩余宽度并贴右；地址等长文本在此宽度内换行（超出省略）
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
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
      onTap: () {},
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

  /// 生日展示：yyyy-MM-dd（接口 birthday 可能是日期时间串，统一截到日）
  String _formatBirthday(DateTime? birthday) {
    if (birthday == null) return '';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${birthday.year}-${two(birthday.month)}-${two(birthday.day)}';
  }
}
