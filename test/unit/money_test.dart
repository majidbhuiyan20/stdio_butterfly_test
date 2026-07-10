import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Money Arithmetic Tests', () {
    test('Decimal should handle 0.0079 * 3 precisely', () {
      final rate = Decimal.parse('0.0079');
      final segments = Decimal.fromInt(3);
      final total = rate * segments;

      // In double: 0.0079 * 3 = 0.023700000000000002
      // In Decimal: should be exactly 0.0237
      expect(total.toString(), '0.0237');
      expect(total, Decimal.parse('0.0237'));
    });

    test('Summing many small amounts should be exact', () {
      final amount = Decimal.parse('0.0001');
      var total = Decimal.zero;

      for (var i = 0; i < 10000; i++) {
        total += amount;
      }

      // 0.0001 * 10000 = 1.0
      expect(total.toString(), '1');
      expect(total, Decimal.fromInt(1));
    });

    test('Decimal should handle multi-provider costs accurately', () {
      final twilioRate = Decimal.parse('0.0750');
      final awsRate = Decimal.parse('0.0450');

      final twilioCost = twilioRate * Decimal.fromInt(110); // 8.25
      final awsCost = awsRate * Decimal.fromInt(91);      // 4.095

      final total = twilioCost + awsCost;

      expect(twilioCost.toString(), '8.25');
      expect(awsCost.toString(), '4.095');
      expect(total.toString(), '12.345');
    });
  });
}
