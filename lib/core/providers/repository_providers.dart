import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_mixed_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../domain/repositories/auth_repository.dart';
import '../../features/cart/data/datasources/cart_mock_datasource.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/member/data/datasources/member_mixed_datasource.dart';
import '../../features/member/data/datasources/member_mock_datasource.dart';
import '../../features/member/data/datasources/member_remote_datasource.dart';
import '../../features/member/data/datasources/member_sign_in_mock_datasource.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/member/domain/repositories/member_sign_in_repository.dart';
import '../../features/notification/data/datasources/notification_mock_datasource.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/order/data/datasources/invoice_mock_datasource.dart';
import '../../features/order/data/datasources/order_mock_datasource.dart';
import '../../features/order/domain/repositories/invoice_repository.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/points/data/datasources/points_mock_datasource.dart';
import '../../features/points/domain/repositories/points_repository.dart';
import '../../features/product/data/datasources/product_mock_datasource.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../../../core/network/providers.dart' show apiClientProvider;

part 'repository_providers.g.dart';

/// ============================================================
/// Repository Providers - 开发/测试环境使用 Mock 实现
/// 真实 API 就绪后，在此处切换为 Remote*Repository 实现
/// ============================================================

/// Auth Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthMixedDataSource(remote: ref.read(remoteAuthDataSourceProvider), mock: MockAuthDataSource());
}

/// Product Repository Provider
@riverpod
ProductRepository productRepository(Ref ref) {
  return MockProductDataSource();
}

/// Cart Repository Provider
@riverpod
CartRepository cartRepository(Ref ref) {
  return MockCartDataSource();
}

/// Order Repository Provider
@riverpod
OrderRepository orderRepository(Ref ref) {
  return MockOrderDataSource();
}

/// Invoice Repository Provider
@riverpod
InvoiceRepository invoiceRepository(Ref ref) {
  // TODO(Mock): 发票中心后端接口尚未定义，当前走 Mock。
  // 接口就绪后改为返回 Remote 实现。
  return MockInvoiceDataSource();
}

/// Member Repository Provider
///
/// ★ Mock / 真实接口切换点（会员模块）★
///
/// 现状：会员等级相关接口已就绪，通过 [MemberMixedDataSource] 走真实接口，
/// 其余会员能力（会员信息 / 权益权限 / 优惠券 / 积分 / 地址…）仍走 Mock。
///
///   - 新增接口就绪 → 在 [MemberMixedDataSource] 中把对应方法改为 `remote.xxx()`；
///   - 全部接口就绪 → 删除 [MemberMixedDataSource]，直接：
///     `return ref.read(memberRemoteDataSourceProvider);`
///   - 需要整体回退 Mock（如离线联调）→ 直接：
///     `return MockMemberDataSource();`
@riverpod
MemberRepository memberRepository(Ref ref) {
  return MemberMixedDataSource(remote: ref.read(memberRemoteDataSourceProvider), mock: MockMemberDataSource());
}

/// Member Sign In Repository Provider
@riverpod
MemberSignInRepository memberSignInRepository(Ref ref) {
  // TODO(Mock): 会员签到后端接口尚未提供，当前走 Mock。
  // 接口就绪后改为返回 MemberSignInRemoteDataSource。
  return MockMemberSignInDataSource();
}

/// Points Repository Provider
///
/// 全量使用 Mock 数据源，其中 getCreditMallHotProducts 会自动注入 apiClient
/// 以调用真实推荐位接口（positioncode=CREDITMALL）。
@riverpod
PointsRepository pointsRepository(Ref ref) {
  return MockPointsDataSource(apiClient: ref.read(apiClientProvider));
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  // TODO(Mock): 通知中心后端接口尚未定义，当前走 Mock。
  // 接口就绪后改为返回 NotificationRemoteDataSource。
  return MockNotificationDataSource();
}

/// 所有 Repository Provider 的聚合
final allRepositoryProviders = [
  authRepositoryProvider,
  productRepositoryProvider,
  cartRepositoryProvider,
  orderRepositoryProvider,
  memberRepositoryProvider,
  memberSignInRepositoryProvider,
  pointsRepositoryProvider,
  notificationRepositoryProvider,
];
