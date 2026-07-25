import 'package:flutter/material.dart';

class IncomeItem {
  const IncomeItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.day,
    required this.monthKey,
    required this.color,
  });

  final String id;
  final String title;
  final double amount;
  final int day;

  /// Ek gelirin ait olduğu ay.
  /// Format: yyyy-MM
  final String monthKey;

  final Color color;

  IncomeItem copyWith({
    String? id,
    String? title,
    double? amount,
    int? day,
    String? monthKey,
    Color? color,
  }) {
    return IncomeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      day: day ?? this.day,
      monthKey: monthKey ?? this.monthKey,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'day': day,
      'monthKey': monthKey,
      'color': color.value,
    };
  }

  factory IncomeItem.fromJson(Map<String, dynamic> json) {
    return IncomeItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      day: ((json['day'] as num?)?.toInt() ?? 1).clamp(1, 31),
      monthKey: json['monthKey'] as String? ?? '',
      color: Color((json['color'] as num?)?.toInt() ?? 0xFF00D59B),
    );
  }
}
