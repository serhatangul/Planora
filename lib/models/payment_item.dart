import 'package:flutter/material.dart';

enum PaymentStatus {
  paid,
  waiting,
  late,
}

class PaymentItem {
  const PaymentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dueDay,
    required this.status,
    required this.color,
    this.isMonthly = true,
    this.monthKey,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final int dueDay;
  final PaymentStatus status;
  final Color color;
  final bool isMonthly;

  /// Tek seferlik ödemeler için hangi aya ait olduğunu tutar.
  /// Format: yyyy-MM
  /// Örnek: 2026-06
  final String? monthKey;

  PaymentItem copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    int? dueDay,
    PaymentStatus? status,
    Color? color,
    bool? isMonthly,
    String? monthKey,
  }) {
    return PaymentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      status: status ?? this.status,
      color: color ?? this.color,
      isMonthly: isMonthly ?? this.isMonthly,
      monthKey: monthKey ?? this.monthKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'dueDay': dueDay,
      'status': status.name,
      'color': color.value,
      'isMonthly': isMonthly,
      'monthKey': monthKey,
    };
  }

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueDay: (json['dueDay'] as num?)?.toInt() ?? 1,
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.waiting,
      ),
      color: Color((json['color'] as num?)?.toInt() ?? 0xFF687086),
      isMonthly: json['isMonthly'] as bool? ?? true,
      monthKey: json['monthKey'] as String?,
    );
  }
}

class BudgetCategory {
  const BudgetCategory({
    required this.title,
    required this.limit,
    required this.used,
    required this.color,
  });

  final String title;
  final double limit;
  final double used;
  final Color color;

  double get ratio {
    if (limit <= 0) return 0;
    return (used / limit).clamp(0, 1.4);
  }

  double get remaining => limit - used;
}
