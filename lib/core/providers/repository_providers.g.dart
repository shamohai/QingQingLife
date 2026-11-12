// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ============================================================
/// Repository Providers - 统一数据源接入层
/// 各 Feature 统一使用对应的 *DataSource 实例提供服务
/// ============================================================
/// Auth Repository Provider

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// ============================================================
/// Repository Providers - 统一数据源接入层
/// 各 Feature 统一使用对应的 *DataSource 实例提供服务
/// ============================================================
/// Auth Repository Provider

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// ============================================================
  /// Repository Providers - 统一数据源接入层
  /// 各 Feature 统一使用对应的 *DataSource 实例提供服务
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

String _$authRepositoryHash() => r'377bf750d397d8f99e40b673a2e55b09f7f0d52c';

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

String _$productRepositoryHash() => r'866682f6beb2eb5740e498240ab58b33ad8a0473';

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

String _$orderRepositoryHash() => r'cf93b7a4616f62708a1c49c1bbeb8df128be8030';

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

String _$invoiceRepositoryHash() => r'8c5464dd99156c1e11750fcd260ae143795d9465';

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

String _$memberRepositoryHash() => r'4f3692a18b5199b7f7c746eba5274b992642540f';

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
    r'afe2fa591cde0043749f8b171e966f5a37f73f3e';

/// Points Repository Provider

@ProviderFor(pointsRepository)
final pointsRepositoryProvider = PointsRepositoryProvider._();

/// Points Repository Provider

final class PointsRepositoryProvider
    extends
        $FunctionalProvider<
          PointsRepository,
          PointsRepository,
          PointsRepository
        >
    with $Provider<PointsRepository> {
  /// Points Repository Provider
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

String _$pointsRepositoryHash() => r'f626b500039a261c6516a595b063bd5ea5de0494';

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
    r'a8309606a96306d49fa7397a0be06389b7bd8263';
