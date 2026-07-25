import 'package:flutter/material.dart';

import '../models/expense_item.dart';
import '../models/income_item.dart';
import '../models/payment_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/planora_empty_state.dart';
import 'edit_payment_screen.dart';
import 'expenses_screen.dart';
import 'extra_income_screen.dart';
import 'add_payment_screen.dart';


String _calendarText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Ödeme Takvimi',
      'en': 'Payment Calendar',
      'ru': 'Календарь',
    },
    'subtitle': {
      'tr': 'Ödeme, harcama ve ek gelirlerini gün bazında takip et.',
      'en': 'Track payments, expenses, and extra income day by day.',
      'ru': 'Отслеживайте платежи, расходы и доп. доходы по дням.',
    },
    'today': {
      'tr': 'Bugüne dön',
      'en': 'Back to today',
      'ru': 'Вернуться к сегодня',
    },
    'extraIncome': {
      'tr': 'Ek gelir',
      'en': 'Extra income',
      'ru': 'Доп. доход',
    },
    'expense': {
      'tr': 'Harcama',
      'en': 'Expense',
      'ru': 'Расход',
    },
    'payment': {
      'tr': 'Ödeme',
      'en': 'Payment',
      'ru': 'Платёж',
    },
    'dayDetails': {
      'tr': 'Gün detayları',
      'en': 'Day details',
      'ru': 'Детали дня',
    },
    'selectDayPrompt': {
      'tr': 'Detayları görmek için takvimden bir gün seç.',
      'en': 'Select a day from the calendar to view details.',
      'ru': 'Выберите день в календаре, чтобы увидеть детали.',
    },
    'noEventsThisDay': {
      'tr': 'Bu günde işlem yok.',
      'en': 'No transactions on this day.',
      'ru': 'В этот день операций нет.',
    },
    'monthlyPaymentList': {
      'tr': 'Bu ayki ödeme listesi',
      'en': 'This month’s payment list',
      'ru': 'Платежи месяца',
    },
    'noPaymentsThisMonth': {
      'tr': 'Bu ay için ödeme görünmüyor.',
      'en': 'No payments for this month.',
      'ru': 'Платежей за этот месяц нет.',
    },
    'emptyCalendarTitle': {
      'tr': 'Takvim henüz boş',
      'en': 'Calendar is empty',
      'ru': 'Календарь пока пуст',
    },
    'emptyCalendarDescription': {
      'tr': 'Ödeme, harcama veya ek gelir eklediğinizde bu ayın takviminde görünecek.',
      'en': 'Payments, expenses, and extra income will appear here once you add them.',
      'ru': 'Платежи, расходы и доп. доходы появятся здесь после добавления.',
    },
    'emptyDayTitle': {
      'tr': 'Bu günde işlem yok',
      'en': 'No activity on this day',
      'ru': 'В этот день нет операций',
    },
    'emptyDayDescription': {
      'tr': 'Seçtiğiniz güne ait ödeme, harcama veya ek gelir kaydı bulunmuyor.',
      'en': 'There are no payments, expenses, or extra income records for the selected day.',
      'ru': 'Для выбранного дня нет платежей, расходов или доп. доходов.',
    },
    'addPayment': {
      'tr': 'Ödeme Ekle',
      'en': 'Add Payment',
      'ru': 'Добавить платёж',
    },
    'addExpense': {
      'tr': 'Harcama Ekle',
      'en': 'Add Expense',
      'ru': 'Добавить расход',
    },

    'paid': {
      'tr': 'Ödendi',
      'en': 'Paid',
      'ru': 'Оплачено',
    },
    'overduePayment': {
      'tr': 'Gecikmiş ödeme',
      'en': 'Overdue payment',
      'ru': 'Просроченный платёж',
    },
    'markWaiting': {
      'tr': 'Bekliyor yap',
      'en': 'Mark waiting',
      'ru': 'Отметить ожидающим',
    },
    'markPaid': {
      'tr': 'Ödendi yap',
      'en': 'Mark paid',
      'ru': 'Отметить оплаченным',
    },
    'lateLegend': {
      'tr': 'Gecikmiş',
      'en': 'Late',
      'ru': 'Просрочено',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _calendarMonthYearLabel(String code, DateTime month) {
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

List<String> _calendarWeekDays(String code) {
  switch (code) {
    case 'en':
      return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    case 'ru':
      return const ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'];
    case 'tr':
    default:
      return const ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
  }
}

String _dayDetailsTitle(String code, int? day) {
  if (day == null) return _calendarText(code, 'dayDetails');

  switch (code) {
    case 'en':
      return 'Day $day details';
    case 'ru':
      return 'Детали $day-го дня';
    case 'tr':
    default:
      return '$day. gün detayları';
  }
}

String _transactionCountText(String code, int count) {
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

String _paymentCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count payments';
    case 'ru':
      return '$count пл.';
    case 'tr':
    default:
      return '$count ödeme';
  }
}

String _paymentDayCategoryText(String code, int day, String category) {
  switch (code) {
    case 'en':
      return 'Day $day · $category';
    case 'ru':
      return '$day-й день · $category';
    case 'tr':
    default:
      return '$day. gün · $category';
  }
}

enum _CalendarEventType {
  payment,
  expense,
  income,
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.day,
    required this.color,
    required this.icon,
    required this.type,
    required this.isPositive,
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
  final _CalendarEventType type;
  final bool isPositive;
  final bool isPaid;
  final bool isLate;
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int? _selectedDay;

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

  void _openPaymentAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: AddPaymentScreen(
            onSaved: () => Navigator.of(context).pop(),
          ),
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

  void _openExtraIncome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const ExtraIncomeScreen(),
        ),
      ),
    );
  }

  String _incomeSubtitle(String code) {
    switch (code) {
      case 'en':
        return 'Extra income';
      case 'ru':
        return 'Дополнительный доход';
      case 'tr':
      default:
        return 'Ek gelir';
    }
  }

  String _paymentSubtitle(String code, PaymentItem payment, bool isPaid, bool isLate, PlanoraController controller) {
    final category = controller.categoryLabel(payment.category);
    if (isPaid) {
      switch (code) {
        case 'en':
          return 'Paid · $category';
        case 'ru':
          return 'Оплачено · $category';
        case 'tr':
        default:
          return 'Ödendi · $category';
      }
    }

    if (isLate) {
      switch (code) {
        case 'en':
          return 'Overdue payment · $category';
        case 'ru':
          return 'Просроченный платёж · $category';
        case 'tr':
        default:
          return 'Gecikmiş ödeme · $category';
      }
    }

    switch (code) {
      case 'en':
        return 'Waiting payment · $category';
      case 'ru':
        return 'Ожидающий платёж · $category';
      case 'tr':
      default:
        return 'Bekleyen ödeme · $category';
    }
  }

  String _expenseSubtitle(String code, ExpenseItem expense, PlanoraController controller) {
    final category = controller.categoryLabel(expense.category);
    switch (code) {
      case 'en':
        return 'Expense · $category';
      case 'ru':
        return 'Расход · $category';
      case 'tr':
      default:
        return 'Harcama · $category';
    }
  }

  List<_CalendarEvent> _eventsForMonth(PlanoraController controller, String lang) {
    final events = <_CalendarEvent>[];

    for (final IncomeItem income in controller.extraIncomesForSelectedMonth) {
      events.add(
        _CalendarEvent(
          id: income.id,
          title: income.title,
          subtitle: _incomeSubtitle(lang),
          amount: income.amount,
          day: income.day,
          color: AppColors.brandGreen,
          icon: Icons.add_chart_rounded,
          type: _CalendarEventType.income,
          isPositive: true,
        ),
      );
    }

    for (final ExpenseItem expense in controller.expensesForSelectedMonth) {
      events.add(
        _CalendarEvent(
          id: expense.id,
          title: expense.title,
          subtitle: controller.categoryLabel(expense.category),
          amount: expense.amount,
          day: expense.day,
          color: AppColors.warning,
          icon: Icons.shopping_bag_rounded,
          type: _CalendarEventType.expense,
          isPositive: false,
        ),
      );
    }

    for (final PaymentItem payment in controller.paymentsForSelectedMonth) {
      final isPaid = controller.isPaymentPaid(payment);
      final isLate = controller.isPaymentLate(payment);

      events.add(
        _CalendarEvent(
          id: payment.id,
          title: controller.defaultPaymentTitleLabel(payment.title),
          subtitle: _paymentSubtitle(lang, payment, isPaid, isLate, controller),
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
          type: _CalendarEventType.payment,
          isPositive: false,
          isPaid: isPaid,
          isLate: isLate,
        ),
      );
    }

    events.sort((a, b) {
      final dayCompare = a.day.compareTo(b.day);
      if (dayCompare != 0) return dayCompare;

      if (a.type != b.type) {
        if (a.type == _CalendarEventType.income) return -1;
        if (b.type == _CalendarEventType.income) return 1;
      }

      return a.title.compareTo(b.title);
    });

    return events;
  }

  Map<int, List<_CalendarEvent>> _groupByDay(List<_CalendarEvent> events) {
    final grouped = <int, List<_CalendarEvent>>{};

    for (final event in events) {
      grouped.putIfAbsent(event.day, () => []);
      grouped[event.day]!.add(event);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selectedMonth = controller.selectedMonth;
        final daysInMonth = PlanoraDateUtils.daysInMonth(selectedMonth);
        final firstOffset = PlanoraDateUtils.firstWeekdayOffset(selectedMonth);
        final totalCells = firstOffset + daysInMonth;
        final today = DateTime.now();

        final lang = controller.appLanguageCode;
        final events = _eventsForMonth(controller, lang);
        final groupedEvents = _groupByDay(events);

        final safeSelectedDay = _selectedDay != null && _selectedDay! <= daysInMonth
            ? _selectedDay
            : today.month == selectedMonth.month && today.year == selectedMonth.year
                ? today.day
                : null;

        final selectedEvents = safeSelectedDay == null
            ? <_CalendarEvent>[]
            : groupedEvents[safeSelectedDay] ?? <_CalendarEvent>[];

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 132),
            children: [
              Text(_calendarText(lang, 'title'), style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                _calendarText(lang, 'subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.changeSelectedMonth(-1);
                            setState(() => _selectedDay = null);
                          },
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              _calendarMonthYearLabel(lang, selectedMonth),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.changeSelectedMonth(1);
                            setState(() => _selectedDay = null);
                          },
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          controller.goToCurrentMonth();
                          setState(() => _selectedDay = DateTime.now().day);
                        },
                        child: Text(
                          _calendarText(lang, 'today'),
                          style: const TextStyle(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _WeekHeader(lang: lang),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalCells,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 6,
                      ),
                      itemBuilder: (context, index) {
                        if (index < firstOffset) {
                          return const SizedBox.shrink();
                        }

                        final day = index - firstOffset + 1;
                        final cellDate = DateTime(selectedMonth.year, selectedMonth.month, day);
                        final dayEvents = groupedEvents[day] ?? const <_CalendarEvent>[];

                        return _CalendarDay(
                          day: day,
                          events: dayEvents,
                          isToday: PlanoraDateUtils.isSameDay(cellDate, today),
                          isSelected: safeSelectedDay == day,
                          onTap: () => setState(() => _selectedDay = day),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _CalendarLegend(lang: lang),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PremiumCard(
                color: const Color(0xFFF9FBFF),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _CalendarSummaryPill(
                        label: _calendarText(lang, 'extraIncome'),
                        value: controller.extraIncomeCount,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CalendarSummaryPill(
                        label: _calendarText(lang, 'expense'),
                        value: controller.expenseCount,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CalendarSummaryPill(
                        label: _calendarText(lang, 'payment'),
                        value: controller.paymentsForSelectedMonth.length,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: _dayDetailsTitle(lang, safeSelectedDay),
                actionLabel: _transactionCountText(lang, selectedEvents.length),
              ),
              const SizedBox(height: 12),
              if (safeSelectedDay == null)
                PlanoraEmptyState(
                  icon: Icons.calendar_month_rounded,
                  title: _calendarText(lang, 'emptyCalendarTitle'),
                  description: _calendarText(lang, 'emptyCalendarDescription'),
                  actionLabel: _calendarText(lang, 'addPayment'),
                  onActionTap: () => _openPaymentAdd(context),
                  secondaryActionLabel: _calendarText(lang, 'addExpense'),
                  onSecondaryActionTap: () => _openExpenses(context),
                  color: AppColors.brandBlue,
                )
              else if (selectedEvents.isEmpty)
                PlanoraEmptyState(
                  icon: Icons.event_available_rounded,
                  title: _calendarText(lang, 'emptyDayTitle'),
                  description: _calendarText(lang, 'emptyDayDescription'),
                  actionLabel: _calendarText(lang, 'addPayment'),
                  onActionTap: () => _openPaymentAdd(context),
                  secondaryActionLabel: _calendarText(lang, 'addExpense'),
                  onSecondaryActionTap: () => _openExpenses(context),
                  color: AppColors.textSecondary,
                )
              else
                ...selectedEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CalendarEventCard(
                      event: event,
                      onTap: () {
                        if (event.type == _CalendarEventType.payment) {
                          _openPaymentEdit(context, event.id);
                        } else if (event.type == _CalendarEventType.expense) {
                          _openExpenses(context);
                        } else {
                          _openExtraIncome(context);
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SectionHeader(
                title: _calendarText(lang, 'monthlyPaymentList'),
                actionLabel: _paymentCountText(lang, controller.paymentsForSelectedMonth.length),
              ),
              const SizedBox(height: 12),
              if (controller.paymentsForSelectedMonth.isEmpty)
                PlanoraEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: _calendarText(lang, 'emptyCalendarTitle'),
                  description: _calendarText(lang, 'emptyCalendarDescription'),
                  color: AppColors.brandBlue,
                )
              else
                ...controller.paymentsForSelectedMonth.map((payment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CalendarPaymentItem(
                      payment: payment,
                      isLate: controller.isPaymentLate(payment),
                      onTap: () => _openPaymentEdit(context, payment.id),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({
    required this.event,
    required this.onTap,
  });

  final _CalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = event.isPositive
        ? AppColors.brandGreen
        : event.isLate
            ? AppColors.danger
            : AppColors.textPrimary;

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      borderColor: event.isLate ? AppColors.danger.withOpacity(0.45) : AppColors.stroke,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(event.icon, color: event.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: event.isPaid ? TextDecoration.lineThrough : null,
                          color: event.isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: event.isLate ? AppColors.danger : AppColors.textSecondary,
                          fontWeight: event.isLate ? FontWeight.w800 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${event.isPositive ? '+' : '-'} ${MoneyFormatter.format(event.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarPaymentItem extends StatelessWidget {
  const _CalendarPaymentItem({
    required this.payment,
    required this.onTap,
    required this.isLate,
  });

  final PaymentItem payment;
  final VoidCallback onTap;
  final bool isLate;

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    final isPaid = controller.isPaymentPaid(payment);

    return Dismissible(
      key: ValueKey(payment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async => controller.removePayment(payment.id),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        borderColor: isLate ? AppColors.danger.withOpacity(0.45) : AppColors.stroke,
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: payment.color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: isPaid
                          ? Icon(Icons.check_rounded, color: payment.color)
                          : Text(
                              '${payment.dueDay}',
                              style: TextStyle(
                                color: payment.color,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PlanoraScope.of(context).defaultPaymentTitleLabel(payment.title),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: isPaid ? TextDecoration.lineThrough : null,
                                color: isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isPaid
                              ? _calendarText(PlanoraScope.of(context).appLanguageCode, 'paid')
                              : isLate
                                  ? _calendarText(PlanoraScope.of(context).appLanguageCode, 'overduePayment')
                                  : _paymentDayCategoryText(PlanoraScope.of(context).appLanguageCode, payment.dueDay, PlanoraScope.of(context).categoryLabel(payment.category)),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isPaid
                                    ? AppColors.brandGreen
                                    : isLate
                                        ? AppColors.danger
                                        : AppColors.textSecondary,
                                fontWeight: isPaid || isLate ? FontWeight.w800 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    MoneyFormatter.format(payment.amount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PaymentStatusButton(
              isPaid: isPaid,
              onTap: () => controller.togglePaymentPaid(payment.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusButton extends StatelessWidget {
  const _PaymentStatusButton({
    required this.isPaid,
    required this.onTap,
  });

  final bool isPaid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPaid ? const Color(0xFFE8FFF6) : const Color(0xFFFFF6E5);
    final textColor = isPaid ? const Color(0xFF0A7A59) : AppColors.warning;
    final icon = isPaid ? Icons.undo_rounded : Icons.check_circle_rounded;
    final label = isPaid ? _calendarText(PlanoraScope.of(context).appLanguageCode, 'markWaiting') : _calendarText(PlanoraScope.of(context).appLanguageCode, 'markPaid');

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final days = _calendarWeekDays(lang);
    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.events,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final List<_CalendarEvent> events;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  bool get _hasLatePayment {
    return events.any((event) => event.isLate);
  }

  bool get _hasIncome {
    return events.any((event) => event.type == _CalendarEventType.income);
  }

  bool get _hasExpense {
    return events.any((event) => event.type == _CalendarEventType.expense);
  }

  bool get _hasPayment {
    return events.any((event) => event.type == _CalendarEventType.payment);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasLatePayment
        ? AppColors.danger
        : isSelected
            ? AppColors.brandBlue
            : isToday
                ? AppColors.brandGreen
                : null;

    final backgroundColor = isSelected
        ? const Color(0xFFEAF0FB)
        : isToday
            ? const Color(0xFFE8FFF6)
            : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor == null ? null : Border.all(color: borderColor, width: 1.2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: _hasLatePayment
                    ? AppColors.danger
                    : isSelected
                        ? AppColors.brandBlue
                        : isToday
                            ? const Color(0xFF0A7A59)
                            : AppColors.textPrimary,
              ),
            ),
            if (events.isNotEmpty)
              Positioned(
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasIncome) const _Dot(color: AppColors.brandGreen),
                    if (_hasExpense) const _Dot(color: AppColors.warning),
                    if (_hasPayment)
                      _Dot(color: _hasLatePayment ? AppColors.danger : AppColors.brandBlue),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendChip(label: _calendarText(lang, 'extraIncome'), color: AppColors.brandGreen),
        _LegendChip(label: _calendarText(lang, 'expense'), color: AppColors.warning),
        _LegendChip(label: _calendarText(lang, 'payment'), color: AppColors.brandBlue),
        _LegendChip(label: _calendarText(lang, 'lateLegend'), color: AppColors.danger),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _CalendarSummaryPill extends StatelessWidget {
  const _CalendarSummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
