import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/repositories/member_repository.dart';
import '../providers/member_addresses_provider.dart';
import '../widgets/address_card.dart';

/// 收货地址列表页（/address）
///
/// 入口：「我的」页功能宫格「收货地址」。
/// 结构（设计稿）：返回栏「收货地址」→ 地址卡片列表（默认地址为蓝色描边 + 勾选圆点）
///   → 底部湖泊背景图 → 底部固定「新增收货地址」按钮。
/// 数据：memberAddressesProvider（调用用户地址列表真实接口）。
/// 新增 / 编辑地址跳转 AddressFormPage（/address/add、/address/edit）。
class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  /// 导航栏底部与第一张卡片的距离（设计稿：卡片顶 92.25 - 导航栏底 74）
  static const double _navToCardGap = 18.25;

  /// 卡片间距（设计稿）
  static const double _cardGap = 17.25;

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(memberAddressesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 底部湖泊背景图（不随内容滚动）
            Positioned(
              top: 504,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset('assets/images/member/about_lake_bg.png', width: double.infinity, fit: BoxFit.fitWidth),
              ),
            ),

            // 前景内容
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildNav(context),
                  const SizedBox(height: _navToCardGap),
                  Expanded(child: _buildContent(addressesAsync)),
                ],
              ),
            ),

            // 底部固定操作栏
            Align(alignment: Alignment.bottomCenter, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  /// 顶部返回栏（标题左对齐）
  Widget _buildNav(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '收货地址',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF000000), height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  /// 地址列表（加载 / 失败 / 空态 / 正常）
  Widget _buildContent(AsyncValue<List<MemberAddress>> addressesAsync) {
    if (addressesAsync.hasError && !addressesAsync.hasValue) {
      return Center(child: AppError(onRetry: () => ref.invalidate(memberAddressesProvider)));
    }
    if (!addressesAsync.hasValue) {
      return const Center(child: AppLoading());
    }
    final addresses = addressesAsync.value!;
    if (addresses.isEmpty) {
      return const AppEmpty(message: '暂无收货地址', icon: Icons.location_on_outlined);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(memberAddressesProvider);
        await ref.read(memberAddressesProvider.future);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.compactPageMargin, 0, AppSpacing.compactPageMargin, 144),
        itemCount: addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: _cardGap),
        itemBuilder: (context, index) {
          final address = addresses[index];
          return AddressCard(
            address: address,
            onSetDefault: address.isDefault ? null : () => _onSetDefault(address),
            onEdit: () => _onEdit(address),
            onDelete: () => _onDelete(address),
          );
        },
      ),
    );
  }

  /// 设为默认地址
  Future<void> _onSetDefault(MemberAddress address) async {
    final id = address.id;
    if (id == null) return;
    final response = await ref.read(memberRepositoryProvider).setDefaultAddress(id);
    if (!mounted) return;
    if (response.success) {
      ref.invalidate(memberAddressesProvider);
      _showSnackBar('默认地址已更新');
    } else {
      _showSnackBar(response.message);
    }
  }

  /// 编辑地址：进入编辑页（带入原地址）
  void _onEdit(MemberAddress address) {
    context.push(RouteNames.addressEdit, extra: address);
  }

  /// 删除地址（二次确认后删除）
  Future<void> _onDelete(MemberAddress address) async {
    final id = address.id;
    if (id == null) return;
    final confirmed = await AppDialog.show(context: context, title: '删除地址', content: '确定要删除该收货地址吗？');
    if (confirmed != true || !mounted) return;
    final response = await ref.read(memberRepositoryProvider).deleteAddress(id);
    if (!mounted) return;
    if (response.success) {
      ref.invalidate(memberAddressesProvider);
      _showSnackBar('地址已删除');
    } else {
      _showSnackBar(response.message);
    }
  }

  /// 新增收货地址：进入新增页（空表单）
  void _onAddAddress() {
    context.push(RouteNames.addressAdd);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  /// 底部固定操作栏（白色，无分割线/阴影）
  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.5, 13, 29.5, 30.5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onAddAddress,
            child: Container(
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21.5),
                gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF1F3573), Color(0xFF3050AE)]),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  '新增收货地址',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white, height: 1.2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
