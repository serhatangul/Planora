import 'package:flutter/material.dart';

import '../models/expense_item.dart';
import '../models/payment_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import 'edit_payment_screen.dart';
import 'expenses_screen.dart';


String _categoryDetailText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'usedLimit': {
      'tr': 'Kullanılan limit',
      'en': 'Used limit',
      'ru': 'Использованный лимит',
    },
    'limitExceeded': {
      'tr': 'Bu kategori limiti aştı.',
      'en': 'This category has exceeded its limit.',
      'ru': 'Эта категория превысила лимит.',
    },
    'limitNear': {
      'tr': 'Bu kategori limite yaklaştı.',
      'en': 'This category is close to its limit.',
      'ru': 'Эта категория близка к лимиту.',
    },
    'limitSafe': {
      'tr': 'Bu kategori kontrol altında.',
      'en': 'This category is under control.',
      'ru': 'Эта категория под контролем.',
    },
    'payments': {
      'tr': 'Ödemeler',
      'en': 'Payments',
      'ru': 'Платежи',
    },
    'expenses': {
      'tr': 'Harcamalar',
      'en': 'Expenses',
      'ru': 'Расходы',
    },
    'categoryMovements': {
      'tr': 'Kategori hareketleri',
      'en': 'Category movements',
      'ru': 'Движения категории',
    },
    'noMovements': {
      'tr': 'Bu kategoride işlem yok.',
      'en': 'No transactions in this category.',
      'ru': 'В этой категории нет операций.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _categoryDetailMonthYearLabel(String code, DateTime month) {
  final months = {
    'tr': [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    'ru': [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ],
  };

  final language = code == 'en' || code == 'ru' ? code : 'tr';
  return '${months[language]![month.month - 1]} ${month.year}';
}

String _categoryDetailMonthSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return '$month category details';
    case 'ru':
      return 'Детали категории за $month';
    case 'tr':
    default:
      return '$month kategori detayları';
  }
}

String _movementCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count transactions';
    case 'ru':
      return '$count операций';
    case 'tr':
    default:
      return '$count işlem';
  }
}

String _recordCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count records';
    case 'ru':
      return '$count записей';
    case 'tr':
    default:
      return '$count kayıt';
  }
}

enum _CategoryMovementType {
  payment,
  expense,
}

class _CategoryMovement {
  const _CategoryMovement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.day,
    required this.color,
    required this.icon,
    required this.type,
    this.isPaid = false,
    this.isLate = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final int day;
  final Color color;
  final IconData icon;
  final _CategoryMovementType type;
  final bool isPaid;
  final bool isLate;
}

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  void _openPaymentEdit(BuildContext context, String paymentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: EditPaymentScreen(paymentId: paymentId),
        ),
      ),
    );
  }

  void _openExpenses(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const ExpensesScreen(),
        ),
      ),
    );
  }

  String _movementPaymentSubtitle(String code, PaymentItem payment, bool isPaid, bool isLate) {
    if (isPaid) {
      switch (code) {
        case 'en':
          return 'Paid · Payment';
        case 'ru':
          return 'Оплачено · Платёж';
        case 'tr':
        default:
          return 'Ödendi · Ödeme';
      }
    }

    if (isLate) {
      switch (code) {
        case 'en':
          return 'Overdue payment';
        case 'ru':
          return 'Просроченный платёж';
        case 'tr':
        default:
          return 'Gecikmiş ödeme';
      }
    }

    switch (code) {
      case 'en':
        return 'Day ${payment.dueDay} · Payment';
      case 'ru':
        return '${payment.dueDay}-й день · Платёж';
      case 'tr':
      default:
        return '${payment.dueDay}. gün · Ödeme';
    }
  }

  String _movementExpenseSubtitle(String code, ExpenseItem expense) {
    switch (code) {
      case 'en':
        return 'Day ${expense.day} · Expense';
      case 'ru':
        return '${expense.day}-й день · Расход';
      case 'tr':
      default:
        return '${expense.day}. gün · Harcama';
    }
  }

  List<_CategoryMovement> _movements(PlanoraController controller, String lang) {
    final movements = <_CategoryMovement>[];

    for (final PaymentItem payment in controller.paymentsForSelectedMonth) {
      if (payment.category != categoryName) continue;

      final isPaid = controller.isPaymentPaid(payment);
      final isLate = controller.isPaymentLate(payment);

      movements.add(
        _CategoryMovement(
          id: payment.id,
          title: payment.title,
          subtitle: _movementPaymentSubtitle(lang, payment, isPaid, isLate),
          amount: payment.amount,
          day: payment.dueDay,
          color: isPaid
              ? AppColors.brandGreen
              : isLate
                  ? AppColors.danger
                  : payment.color,
          icon: isPaid
              ? Icons.check_rounded
              : isLate
                  ? Icons.warning_rounded
                  : Icons.receipt_long_rounded,
          type: _CategoryMovementType.payment,
          isPaid: isPaid,
          isLate: isLate,
        ),
      );
    }

    for (final ExpenseItem expense in controller.expensesForSelectedMonth) {
      if (expense.category != categoryName) continue;

      movements.add(
        _CategoryMovement(
          id: expense.id,
          title: expense.title,
          subtitle: _movementExpenseSubtitle(lang, expense),
          amount: expense.amount,
          day: expense.day,
          color: AppColors.warning,
          icon: Icons.shopping_bag_rounded,
          type: _CategoryMovementType.expense,
        ),
      );
    }

    movements.sort((a, b) {
      final dayCompare = a.day.compareTo(b.day);
      if (dayCompare != 0) return dayCompare;

      if (a.type != b.type) {
        if (a.type == _CategoryMovementType.expense) return 1;
        return -1;
      }

      return a.title.compareTo(b.title);
    });

    return movements;
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final matchingSummary = controller.categorySummary
                .where((category) => category.title == categoryName)
                .toList();

            final summary = matchingSummary.isEmpty ? null : matchingSummary.first;

            final lang = controller.appLanguageCode;
            final movements = _movements(controller, lang);
            final paymentTotal = controller.paymentsForSelectedMonth
                .where((payment) => payment.category == categoryName)
                .fold<double>(0, (sum, payment) => sum + payment.amount);

            final expenseTotal = controller.expensesForSelectedMonth
                .where((expense) => expense.category == categoryName)
                .fold<double>(0, (sum, expense) => sum + expense.amount);

            final used = summary?.used ?? paymentTotal + expenseTotal;
            final limit = summary?.limit ?? controller.categoryLimit(categoryName);
            final ratio = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
            final color = summary?.color ?? AppColors.brandBlue;
            final isExceeded = limit > 0 && used > limit;
            final isNearLimit = !isExceeded && limit > 0 && used / limit >= 0.85;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.categoryLabel(categoryName),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _categoryDetailMonthSubtitle(lang, _categoryDetailMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  borderColor: isExceeded
                      ? AppColors.danger.withOpacity(0.40)
                      : isNearLimit
                          ? AppColors.warning.withOpacity(0.35)
                          : color.withOpacity(0.22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(Icons.folder_rounded, color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _categoryDetailText(lang, 'usedLimit'),
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${MoneyFormatter.format(used)} / ${MoneyFormatter.format(limit)}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(ratio * 100).round()}%',
                            style: TextStyle(
                              color: isExceeded
                                  ? AppColors.danger
                                  : isNearLimit
                                      ? AppColors.warning
                                      : AppColors.brandGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProgressLine(value: ratio),
                      const SizedBox(height: 12),
                      Text(
                        isExceeded
                            ? _categoryDetailText(lang, 'limitExceeded')
                            : isNearLimit
                                ? _categoryDetailText(lang, 'limitNear')
                                : _categoryDetailText(lang, 'limitSafe'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isExceeded
                                  ? AppColors.danger
                                  : isNearLimit
                                      ? AppColors.warning
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: _categoryDetailText(lang, 'payments'),
                        value: MoneyFormatter.format(paymentTotal),
                        count: controller.paymentsForSelectedMonth
                            .where((payment) => payment.category == categoryName)
                            .length,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: _categoryDetailText(lang, 'expenses'),
                        value: MoneyFormatter.format(expenseTotal),
                        count: controller.expensesForSelectedMonth
                            .where((expense) => expense.category == categoryName)
                            .length,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: _categoryDetailText(lang, 'categoryMovements'),
                  actionLabel: _movementCountText(lang, movements.length),
                ),
                const SizedBox(height: 12),
                if (movements.isEmpty)
                  PremiumCard(
                    child: Column(
                      children: [
                        const Icon(Icons.folder_off_rounded, color: AppColors.textSecondary, size: 38),
                        const SizedBox(height: 10),
                        Text(
                          _categoryDetailText(lang, 'noMovements'),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...movements.map(
                    (movement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MovementCard(
                        movement: movement,
                        onTap: () {
                          if (movement.type == _CategoryMovementType.payment) {
                            _openPaymentEdit(context, movement.id);
                          } else {
                            _openExpenses(context);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });

  final String label;
  final String value;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_recordCountText(PlanoraScope.of(context).appLanguageCode, count), style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({
    required this.movement,
    required this.onTap,
  });

  final _CategoryMovement movement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = movement.isLate ? AppColors.danger : AppColors.textPrimary;

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      borderColor: movement.isLate ? AppColors.danger.withOpacity(0.45) : AppColors.stroke,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: movement.color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(movement.icon, color: movement.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: movement.isPaid ? TextDecoration.lineThrough : null,
                          color: movement.isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    movement.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: movement.isLate ? AppColors.danger : AppColors.textSecondary,
                          fontWeight: movement.isLate ? FontWeight.w800 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              MoneyFormatter.format(movement.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                  ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
