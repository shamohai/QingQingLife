import 'package:intl/intl.dart';

/// 精确金额值对象，内部以 int 分 存储，杜绝 double 精度误差。
class Money {
  final int cents;

  const Money(this.cents);

  factory Money.fromYuan(double yuan) => Money((yuan * 100).round());
  factory Money.fromCents(int cents) => Money(cents);
  static const zero = Money(0);

  String toYuanString() => (cents / 100).toStringAsFixed(2);

  String format({String currency = '¥'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return currency + formatter.format(cents / 100);
  }

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator *(int multiplier) => Money(cents * multiplier);

  bool operator >(Money other) => cents > other.cents;
  bool operator <(Money other) => cents < other.cents;
  bool operator >=(Money other) => cents >= other.cents;
  bool operator <=(Money other) => cents <= other.cents;

  bool get isZero => cents == 0;
  bool get isPositive => cents > 0;
  bool get isNegative => cents < 0;

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;
  @override
  int get hashCode => cents.hashCode;
  @override
  String toString() => 'Money(cents: ' + cents.toString() + ')';
}
