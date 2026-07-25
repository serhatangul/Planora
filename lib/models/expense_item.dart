import 'package:flutter/material.dart';

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.day,
    required this.monthKey,
    required this.color,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final int day;

  /// Harcamanın ait olduğu ay.
  /// Format: yyyy-MM
  final String monthKey;

  final Color color;

  ExpenseItem copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    int? day,
    String? monthKey,
    Color? color,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
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
      'category': category,
      'amount': amount,
      'day': day,
      'monthKey': monthKey,
      'color': color.value,
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      day: ((json['day'] as num?)?.toInt() ?? 1).clamp(1, 31),
      monthKey: json['monthKey'] as String? ?? '',
      color: Color((json['color'] as num?)?.toInt() ?? 0xFF687086),
    );
  }
}
