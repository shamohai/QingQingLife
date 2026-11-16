import 'local_storage.dart';

/// 《用户隐私政策》同意状态存储。
///
/// 仅记录用户是否已在登录页同意隐私政策，用于决定是否初始化第三方统计 SDK。
class PrivacyConsentStorage {
  PrivacyConsentStorage({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  static const _acceptedKey = 'privacy_policy_accepted';

  final LocalStorage _storage;

  Future<bool> isAccepted() async => (await _storage.getBool(_acceptedKey)) ?? false;

  Future<void> setAccepted(bool accepted) async {
    if (accepted) {
      await _storage.putBool(_acceptedKey, true);
    } else {
      await _storage.remove(_acceptedKey);
    }
  }
}
