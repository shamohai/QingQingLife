import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';

/// ApiClient Provider，全局单例，通过 SecureStorage 注入 Token
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(securityStorageProvider);
  return ApiClient(storage: storage);
});

/// SecureStorage Provider
final securityStorageProvider = Provider<SecureStorage>((_) => SecureStorage());

/// LocalStorage Provider
final localStorageProvider = Provider<LocalStorage>((_) => LocalStorage());