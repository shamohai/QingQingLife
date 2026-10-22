// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ============================================================
/// Repository Providers - 开发/测试环境使用 Mock 实现
/// 真实 API 就绪后，在此处切换为 Remote*Repository 实现
/// ============================================================
/// Auth Repository Provider

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// ============================================================
/// Repository Providers - 开发/测试环境使用 Mock 实现
/// 真实 API 就绪后，在此处切换为 Remote*Repository 实现
/// ============================================================
/// Auth Repository Provider

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// ============================================================
  /// Repository Providers - 开发/测试环境使用 Mock 实现
  /// 真实 API 就绪后，在此处切换为 Remote*Repository 实现
  /// ============================================================
  /// Auth Repository Provider
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'c3a391fe0ace4749b9e4ac103934d5cefa6cbfe9';

/// Product Repository Provider

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

/// Product Repository Provider

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  /// Product Repository Provider
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'18d5ebb994b77f8be993a6e1f385f724fc57e4e7';

/// Cart Repository Provider

@ProviderFor(cartRepository)
final cartRepositoryProvider = CartRepositoryProvider._();

/// Cart Repository Provider

final class CartRepositoryProvider
    extends
        $FunctionalProvider<
          CartPageRepository,
          CartPageRepository,
          CartPageRepository
        >
    with $Provider<CartPageRepository> {
  /// Cart Repository Provider
  CartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartRepositoryHash();

  @$internal
  @override
  $ProviderElement<CartPageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CartPageRepository create(Ref ref) {
    return cartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartPageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartPageRepository>(value),
    );
  }
}

String _$cartRepositoryHash() => r'4f84a94e7963f4180c1bd7d32bcf9e84cb17a8eb';

/// Order Repository Provider

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

/// Order Repository Provider

final class OrderRepositoryProvider
    extends
        $FunctionalProvider<OrderRepository, OrderRepository, OrderRepository>
    with $Provider<OrderRepository> {
  /// Order Repository Provider
  OrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'66c4f1582b578137a3b5f755281b6d7a0937aac8';

/// Invoice Repository Provider

@ProviderFor(invoiceRepository)
final invoiceRepositoryProvider = InvoiceRepositoryProvider._();

/// Invoice Repository Provider

final class InvoiceRepositoryProvider
    extends
        $FunctionalProvider<
          InvoiceRepository,
          InvoiceRepository,
          InvoiceRepository
        >
    with $Provider<InvoiceRepository> {
  /// Invoice Repository Provider
  InvoiceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invoiceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invoiceRepositoryHash();

  @$internal
  @override
  $ProviderElement<InvoiceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvoiceRepository create(Ref ref) {
    return invoiceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvoiceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvoiceRepository>(value),
    );
  }
}

String _$invoiceRepositoryHash() => r'5bc0bfc2efc8230227f64c818835bf7c3dbd78dd';

/// Member Repository Provider

@ProviderFor(memberRepository)
final memberRepositoryProvider = MemberRepositoryProvider._();

/// Member Repository Provider

final class MemberRepositoryProvider
    extends
        $FunctionalProvider<
          MemberRepository,
          MemberRepository,
          MemberRepository
        >
    with $Provider<MemberRepository> {
  /// Member Repository Provider
  MemberRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberRepository create(Ref ref) {
    return memberRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberRepository>(value),
    );
  }
}

String _$memberRepositoryHash() => r'45800a821657242a9f96f3c45510b94189cc8ca5';

/// Member Sign In Repository Provider

@ProviderFor(memberSignInRepository)
final memberSignInRepositoryProvider = MemberSignInRepositoryProvider._();

/// Member Sign In Repository Provider

final class MemberSignInRepositoryProvider
    extends
        $FunctionalProvider<
          MemberSignInRepository,
          MemberSignInRepository,
          MemberSignInRepository
        >
    with $Provider<MemberSignInRepository> {
  /// Member Sign In Repository Provider
  MemberSignInRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberSignInRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberSignInRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberSignInRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberSignInRepository create(Ref ref) {
    return memberSignInRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberSignInRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberSignInRepository>(value),
    );
  }
}

String _$memberSignInRepositoryHash() =>
    r'd948153f3d342d5597a9df67bbd7ade68915460f';

/// Points Repository Provider
///
/// 全量使用 Mock 数据源，其中 getRecommendProductList 会自动注入 apiClient
/// 以调用真实推荐位接口（positioncode 由调用方指定）。

@ProviderFor(pointsRepository)
final pointsRepositoryProvider = PointsRepositoryProvider._();

/// Points Repository Provider
///
/// 全量使用 Mock 数据源，其中 getRecommendProductList 会自动注入 apiClient
/// 以调用真实推荐位接口（positioncode 由调用方指定）。

final class PointsRepositoryProvider
    extends
        $FunctionalProvider<
          PointsRepository,
          PointsRepository,
          PointsRepository
        >
    with $Provider<PointsRepository> {
  /// Points Repository Provider
  ///
  /// 全量使用 Mock 数据源，其中 getRecommendProductList 会自动注入 apiClient
  /// 以调用真实推荐位接口（positioncode 由调用方指定）。
  PointsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PointsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PointsRepository create(Ref ref) {
    return pointsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PointsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PointsRepository>(value),
    );
  }
}

String _$pointsRepositoryHash() => r'1c5013a0dc464dd3d6ca634c4ac1e3707cdcf24e';

/// Notification Repository Provider

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// Notification Repository Provider

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  /// Notification Repository Provider
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'0ea9f8b5fc10ccffe645cb3857eb4cdac3c4d4b0';

