import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/member_repository.dart';

/// 会员收货地址列表（「账号安全」页「我的地址」行展示用）
///
/// 数据源：MemberRepository.getAddresses()（真实接口：POST /api/sys/getuseraddresslist）。
final memberAddressesProvider = FutureProvider<List<MemberAddress>>((ref) async {
  final repository = ref.watch(memberRepositoryProvider);
  final response = await repository.getAddresses();
  return response.success ? (response.data ?? const <MemberAddress>[]) : const <MemberAddress>[];
});
