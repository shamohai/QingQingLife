/// 积分商城充值/接收手机号校验规则：11 位纯数字，以 1 开头。
class RechargeMobileValidator {
  RechargeMobileValidator._();

  static final RegExp _pattern = RegExp(r'^1\d{10}$');

  static const String errorMessage = '请输入正确的11位手机号';

  static bool isValid(String? value) => value != null && _pattern.hasMatch(value.trim());
}
