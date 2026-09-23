import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_mixed_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../domain/repositories/auth_repository.dart';
import '../../features/cart/data/datasources/cart_mock_datasource.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/member/data/datasources/member_mock_datasource.dart';
import '../../features/member/domain/repositories/member_repository.dart';
import '../../features/order/data/datasources/order_mock_datasource.dart';
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

/// Member Repository Provider
@riverpod
MemberRepository memberRepository(Ref ref) {
  return MockMemberDataSource();
}

/// Points Repository Provider
///
/// 全量使用 Mock 数据源，其中 getCreditMallHotProducts 会自动注入 apiClient
/// 以调用真实推荐位接口（positioncode=CREDITMALL）。
@riverpod
PointsRepository pointsRepository(Ref ref) {
  return MockPointsDataSource(apiClient: ref.read(apiClientProvider));
}

/// 所有 Repository Provider 的聚合
final allRepositoryProviders = [
  authRepositoryProvider,
  productRepositoryProvider,
  cartRepositoryProvider,
  orderRepositoryProvider,
  memberRepositoryProvider,
  pointsRepositoryProvider,
];
