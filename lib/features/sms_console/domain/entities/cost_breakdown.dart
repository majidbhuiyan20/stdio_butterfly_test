import 'package:decimal/decimal.dart';

class CostBreakdown {
  final String currency;
  final Decimal totalCost;
  final List<CostRow> rows;

  CostBreakdown({
    required this.currency,
    required this.totalCost,
    required this.rows,
  });
}

class CostRow {
  final String provider;
  final Decimal totalCost;
  final int messageCount;

  CostRow({
    required this.provider,
    required this.totalCost,
    required this.messageCount,
  });
}
