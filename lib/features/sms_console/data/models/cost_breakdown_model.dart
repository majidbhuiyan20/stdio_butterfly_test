import 'package:decimal/decimal.dart';
import '../../domain/entities/cost_breakdown.dart';

class CostBreakdownModel extends CostBreakdown {
  CostBreakdownModel({
    required super.currency,
    required super.totalCost,
    required super.rows,
  });

  factory CostBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CostBreakdownModel(
      currency: json['currency'] as String,
      totalCost: Decimal.parse(json['totalCost'] as String),
      rows: (json['rows'] as List<dynamic>)
          .map((e) => CostRowModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CostRowModel extends CostRow {
  CostRowModel({
    required super.provider,
    required super.totalCost,
    required super.messageCount,
  });

  factory CostRowModel.fromJson(Map<String, dynamic> json) {
    return CostRowModel(
      provider: json['provider'] as String,
      totalCost: Decimal.parse(json['totalCost'] as String),
      messageCount: json['messageCount'] as int,
    );
  }
}
