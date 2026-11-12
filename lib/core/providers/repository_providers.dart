import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/member/data/datasources/member_datasource.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/member/domain/repositories/member_sign_in_repository.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/order/data/datasources/invoice_datasource.dart';
import '../../features/order/data/datasources/order_datasource.dart';
import '../../features/order/domain/repositories/invoice_repository.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/points/data/datasources/points_datasource.dart';
import '../../features/points/domain/repositories/points_repository.dart';
import '../../features/product/data/datasources/product_datasource.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../network/providers.dart' show apiClientProvider;

part 'repository_providers.g.dart';

/// ============================================================
/// Repository Providers - 统一数据源接入层
/// 各 Feature 统一使用对应的 *DataSource 实例提供服务
/// ============================================================

/// Auth Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthDataSource(apiClient: ref.read(apiClientProvider));
}

/// Product Repository Provider
@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductDataSource(apiClient: ref.read(apiClientProvider));
}

/// Order Repository Provider
@riverpod
OrderRepository orderRepository(Ref ref) {
  return OrderDataSource(apiClient: ref.read(apiClientProvider));
}

/// Invoice Repository Provider
@riverpod
InvoiceRepository invoiceRepository(Ref ref) {
  return InvoiceDataSource(apiClient: ref.read(apiClientProvider));
}

/// Member Repository Provider
@riverpod
MemberRepository memberRepository(Ref ref) {
  return MemberDataSource(apiClient: ref.read(apiClientProvider));
}

/// Member Sign In Repository Provider
@riverpod
MemberSignInRepository memberSignInRepository(Ref ref) {
  return MemberDataSource(apiClient: ref.read(apiClientProvider));
}

/// Points Repository Provider
@riverpod
PointsRepository pointsRepository(Ref ref) {
  return PointsDataSource(apiClient: ref.read(apiClientProvider));
}

/// Notification Repository Provider
@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRemoteDataSource(ref.read(apiClientProvider));
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
