import 'package:flutter_test/flutter_test.dart';
import 'package:qingqinglife/core/utils/money.dart';

void main() {
  group('Money', () {
    test('fromYuan creates correct cents', () {
      expect(Money.fromYuan(99.90).cents, equals(9990));
      expect(Money.fromYuan(0.01).cents, equals(1));
      expect(Money.fromYuan(0.00).cents, equals(0));
      expect(Money.fromYuan(100.00).cents, equals(10000));
    });

    test('fromCents creates correct cents', () {
      expect(Money.fromCents(9990).cents, equals(9990));
      expect(Money.fromCents(0).cents, equals(0));
    });

    test('zero is zero', () {
      expect(Money.zero.cents, equals(0));
      expect(Money.zero.isZero, isTrue);
    });

    test('format uses yen by default', () {
      expect(Money.fromCents(9990).format(), equals('¥99.90'));
      expect(Money.fromCents(0).format(), equals('¥0.00'));
      expect(Money.fromCents(1).format(), equals('¥0.01'));
      expect(Money.fromCents(123456).format(), equals('¥1,234.56'));
    });

    test('format with custom currency', () {
      expect(Money.fromCents(500).format(currency: 'US dollars'), equals('US dollars5.00'));
    });

    test('toYuanString', () {
      expect(Money.fromCents(9990).toYuanString(), equals('99.90'));
      expect(Money.fromCents(100).toYuanString(), equals('1.00'));
      expect(Money.fromCents(1).toYuanString(), equals('0.01'));
    });

    test('arithmetic operations', () {
      final a = Money.fromCents(9990);
      final b = Money.fromCents(100);
      expect((a + b).cents, equals(10090));
      expect((a - b).cents, equals(9890));
      expect((a * 2).cents, equals(19980));
    });

    test('comparison operators', () {
      final a = Money.fromCents(100);
      final b = Money.fromCents(200);
      final c = Money.fromCents(100);
      expect(a > b, isFalse);
      expect(a < b, isTrue);
      expect(a >= c, isTrue);
      expect(a <= c, isTrue);
    });

    test('isPositive and isNegative', () {
      expect(Money.fromCents(100).isPositive, isTrue);
      expect(Money.fromCents(-100).isPositive, isFalse);
      expect(Money.fromCents(-100).isNegative, isTrue);
      expect(Money.fromCents(100).isNegative, isFalse);
      expect(Money.zero.isPositive, isFalse);
      expect(Money.zero.isNegative, isFalse);
    });

    test('equality', () {
      expect(Money.fromCents(100), equals(Money.fromCents(100)));
      expect(Money.fromCents(100), isNot(equals(Money.fromCents(200))));
    });

    test('toString', () {
      expect(Money.fromCents(9990).toString(), equals('Money(cents: 9990)'));
    });
  });
}
