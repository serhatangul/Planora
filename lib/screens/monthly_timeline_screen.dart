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

enum _TimelineEntryType {
  payment,
  expense,
  income,
}

class _TimelineEntry {
  const _TimelineEntry({
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
  final _TimelineEntryType type;
  final bool isPositive;
  final bool isPaid;
  final bool isLate;
}

enum _TimelineFilter {
  all,
  income,
  expense,
  payment,
  late,
}

class MonthlyTimelineScreen extends StatefulWidget {
  const MonthlyTimelineScreen({super.key});

  @override
  State<MonthlyTimelineScreen> createState() => _MonthlyTimelineScreenState();
}

class _MonthlyTimelineScreenState extends State<MonthlyTimelineScreen> {
  final _searchController = TextEditingController();
  _TimelineFilter _filter = _TimelineFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<_TimelineEntry> _allEntries(PlanoraController controller) {
    final lang = controller.appLanguageCode;
    final entries = <_TimelineEntry>[];

    for (final IncomeItem income in controller.extraIncomesForSelectedMonth) {
      entries.add(
        _TimelineEntry(
          id: income.id,
          title: income.title,
          subtitle: _timelineText(lang, 'extraIncome'),
          amount: income.amount,
          day: income.day,
          color: AppColors.brandGreen,
          icon: Icons.add_chart_rounded,
          type: _TimelineEntryType.income,
          isPositive: true,
        ),
      );
    }

    for (final ExpenseItem expense in controller.expensesForSelectedMonth) {
      entries.add(
        _TimelineEntry(
          id: expense.id,
          title: expense.title,
          subtitle: controller.categoryLabel(expense.category),
          amount: expense.amount,
          day: expense.day,
          color: AppColors.warning,
          icon: Icons.shopping_bag_rounded,
          type: _TimelineEntryType.expense,
          isPositive: false,
        ),
      );
    }

    for (final PaymentItem payment in controller.paymentsForSelectedMonth) {
      final isPaid = controller.isPaymentPaid(payment);
      final isLate = controller.isPaymentLate(payment);

      entries.add(
        _TimelineEntry(
          id: payment.id,
          title: controller.defaultPaymentTitleLabel(payment.title),
          subtitle: isPaid
              ? _paymentTimelineSubtitle(lang, 'paid', controller.categoryLabel(payment.category))
              : isLate
                  ? _paymentTimelineSubtitle(lang, 'late', controller.categoryLabel(payment.category))
                  : _paymentTimelineSubtitle(lang, 'waiting', controller.categoryLabel(payment.category)),
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
          type: _TimelineEntryType.payment,
          isPositive: false,
          isPaid: isPaid,
          isLate: isLate,
        ),
      );
    }

    entries.sort((a, b) {
      final dayCompare = a.day.compareTo(b.day);
      if (dayCompare != 0) return dayCompare;

      if (a.type != b.type) {
        if (a.type == _TimelineEntryType.income) return -1;
        if (b.type == _TimelineEntryType.income) return 1;
      }

      return a.title.compareTo(b.title);
    });

    return entries;
  }

  List<_TimelineEntry> _filteredEntries(PlanoraController controller) {
    final query = _searchController.text.trim().toLowerCase();

    var entries = _allEntries(controller);

    switch (_filter) {
      case _TimelineFilter.all:
        break;
      case _TimelineFilter.income:
        entries = entries.where((entry) => entry.type == _TimelineEntryType.income).toList();
        break;
      case _TimelineFilter.expense:
        entries = entries.where((entry) => entry.type == _TimelineEntryType.expense).toList();
        break;
      case _TimelineFilter.payment:
        entries = entries.where((entry) => entry.type == _TimelineEntryType.payment).toList();
        break;
      case _TimelineFilter.late:
        entries = entries.where((entry) => entry.isLate).toList();
        break;
    }

    if (query.isNotEmpty) {
      entries = entries.where((entry) {
        return entry.title.toLowerCase().contains(query) ||
            entry.subtitle.toLowerCase().contains(query) ||
            entry.amount.round().toString().contains(query) ||
            entry.day.toString().contains(query);
      }).toList();
    }

    return entries;
  }

  Map<int, List<_TimelineEntry>> _groupByDay(List<_TimelineEntry> entries) {
    final grouped = <int, List<_TimelineEntry>>{};

    for (final entry in entries) {
      grouped.putIfAbsent(entry.day, () => []);
      grouped[entry.day]!.add(entry);
    }

    return grouped;
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
            final lang = controller.appLanguageCode;
            final allEntries = _allEntries(controller);
            final entries = _filteredEntries(controller);
            final grouped = _groupByDay(entries);
            final days = grouped.keys.toList()..sort();

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
                        _timelineText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _timelineSubtitle(lang, _timelineMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timelineText(lang, 'monthSummary'),
                        style: const TextStyle(
                          color: Color(0xFFC8D3FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryMini(
                              label: _timelineText(lang, 'extraIncome'),
                              value: MoneyFormatter.format(controller.extraIncomeTotal),
                              color: AppColors.brandGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryMini(
                              label: _timelineText(lang, 'expense'),
                              value: MoneyFormatter.format(controller.expensesTotal),
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryMini(
                              label: _timelineText(lang, 'payment'),
                              value: MoneyFormatter.format(controller.plannedPayments),
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: _timelineText(lang, 'extraIncome'),
                        icon: Icons.add_chart_rounded,
                        onTap: () => _openExtraIncome(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        label: _timelineText(lang, 'expense'),
                        icon: Icons.shopping_bag_rounded,
                        onTap: () => _openExpenses(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _timelineText(lang, 'searchHint'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.4),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TimelineFilterChip(
                        label: _timelineText(lang, 'all'),
                        active: _filter == _TimelineFilter.all,
                        onTap: () => setState(() => _filter = _TimelineFilter.all),
                      ),
                      _TimelineFilterChip(
                        label: _timelineText(lang, 'extraIncome'),
                        active: _filter == _TimelineFilter.income,
                        onTap: () => setState(() => _filter = _TimelineFilter.income),
                      ),
                      _TimelineFilterChip(
                        label: _timelineText(lang, 'expense'),
                        active: _filter == _TimelineFilter.expense,
                        onTap: () => setState(() => _filter = _TimelineFilter.expense),
                      ),
                      _TimelineFilterChip(
                        label: _timelineText(lang, 'payment'),
                        active: _filter == _TimelineFilter.payment,
                        onTap: () => setState(() => _filter = _TimelineFilter.payment),
                      ),
                      _TimelineFilterChip(
                        label: _timelineText(lang, 'lateFilter'),
                        active: _filter == _TimelineFilter.late,
                        onTap: () => setState(() => _filter = _TimelineFilter.late),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SectionHeader(
                  title: _timelineText(lang, 'timeline'),
                  actionLabel: _entryCountText(lang, entries.length),
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  PlanoraEmptyState(
                    icon: allEntries.isEmpty
                        ? Icons.timeline_rounded
                        : Icons.search_off_rounded,
                    title: allEntries.isEmpty
                        ? _timelineText(lang, 'emptyMonthTitle')
                        : _timelineText(lang, 'emptyFilterTitle'),
                    description: allEntries.isEmpty
                        ? _timelineText(lang, 'emptyMonthDescription')
                        : _timelineText(lang, 'emptyFilterDescription'),
                    actionLabel: allEntries.isEmpty ? _timelineText(lang, 'addExpense') : null,
                    onActionTap: allEntries.isEmpty ? () => _openExpenses(context) : null,
                    color: AppColors.brandBlue,
                  )
                else
                  ...days.map(
                    (day) => _DayGroup(
                      lang: lang,
                      day: day,
                      entries: grouped[day]!,
                      onEntryTap: (entry) {
                        if (entry.type == _TimelineEntryType.payment) {
                          _openPaymentEdit(context, entry.id);
                        } else if (entry.type == _TimelineEntryType.expense) {
                          _openExpenses(context);
                        } else {
                          _openExtraIncome(context);
                        }
                      },
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



String _timelineMonthYearLabel(String code, DateTime month) {
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

String _timelineText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'extraIncome': {'tr': 'Ek gelir', 'en': 'Extra income', 'ru': 'Доп. доход'},
    'expense': {'tr': 'Harcama', 'en': 'Expense', 'ru': 'Расход'},
    'payment': {'tr': 'Ödeme', 'en': 'Payment', 'ru': 'Платёж'},
    'title': {'tr': 'İşlem akışı', 'en': 'Transaction timeline', 'ru': 'Лента операций'},
    'monthSummary': {'tr': 'Ay özeti', 'en': 'Month summary', 'ru': 'Итоги месяца'},
    'searchHint': {'tr': 'İşlem, kategori, tutar veya gün ara', 'en': 'Search transaction, category, amount, or day', 'ru': 'Поиск по операции, категории, сумме или дню'},
    'all': {'tr': 'Tümü', 'en': 'All', 'ru': 'Все'},
    'lateFilter': {'tr': 'Gecikmiş', 'en': 'Late', 'ru': 'Просрочено'},
    'timeline': {'tr': 'Zaman çizelgesi', 'en': 'Timeline', 'ru': 'Хронология'},
    'emptyMonthTitle': {'tr': 'Bu ay henüz işlem yok', 'en': 'No transactions this month yet', 'ru': 'В этом месяце пока нет операций'},
    'emptyFilterTitle': {'tr': 'Filtreye uygun işlem yok', 'en': 'No transactions match the filter', 'ru': 'Нет операций по фильтру'},
    'emptyMonthDescription': {'tr': 'Ödeme, harcama veya ek gelir eklediğinde bu ayın akışı gün gün burada oluşur.', 'en': 'When you add payments, expenses, or extra income, this month’s daily flow appears here.', 'ru': 'Когда вы добавите платежи, расходы или доп. доходы, дневная лента месяца появится здесь.'},
    'emptyFilterDescription': {'tr': 'Arama kelimesini veya üstteki filtreleri değiştirerek tekrar deneyebilirsin.', 'en': 'Try changing the search term or the filters above.', 'ru': 'Попробуйте изменить поисковый запрос или фильтры выше.'},
    'addExpense': {'tr': 'Harcama Ekle', 'en': 'Add Expense', 'ru': 'Добавить расход'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _timelineSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return 'Payments, expenses, and extra income in $month';
    case 'ru':
      return 'Платежи, расходы и доп. доходы за $month';
    case 'tr':
    default:
      return '$month içindeki ödeme, harcama ve ek gelirler';
  }
}

String _paymentTimelineSubtitle(String code, String status, String category) {
  switch (code) {
    case 'en':
      if (status == 'paid') return 'Paid · $category';
      if (status == 'late') return 'Late payment · $category';
      return 'Waiting payment · $category';
    case 'ru':
      if (status == 'paid') return 'Оплачено · $category';
      if (status == 'late') return 'Просроченный платёж · $category';
      return 'Ожидающий платёж · $category';
    case 'tr':
    default:
      if (status == 'paid') return 'Ödendi · $category';
      if (status == 'late') return 'Gecikmiş ödeme · $category';
      return 'Bekleyen ödeme · $category';
  }
}

String _entryCountText(String code, int count) {
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

String _dayLabel(String code, int day) {
  switch (code) {
    case 'en':
      return 'Day $day';
    case 'ru':
      return '$day-й день';
    case 'tr':
    default:
      return '$day. gün';
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.lang,
    required this.day,
    required this.entries,
    required this.onEntryTap,
  });

  final String lang;
  final int day;
  final List<_TimelineEntry> entries;
  final ValueChanged<_TimelineEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    final totalPositive = entries
        .where((entry) => entry.isPositive)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final totalNegative = entries
        .where((entry) => !entry.isPositive)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 18 + (entries.length * 70),
                  color: AppColors.stroke,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dayLabel(lang, day),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '+${MoneyFormatter.format(totalPositive)} / -${MoneyFormatter.format(totalNegative)}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TimelineEntryRow(
                        entry: entry,
                        onTap: () => onEntryTap(entry),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({
    required this.entry,
    required this.onTap,
  });

  final _TimelineEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = entry.isPositive
        ? AppColors.brandGreen
        : entry.isLate
            ? AppColors.danger
            : AppColors.textPrimary;

    return Material(
      color: AppColors.softBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(entry.icon, color: entry.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: entry.isPaid ? TextDecoration.lineThrough : null,
                            color: entry.isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: entry.isLate ? AppColors.danger : AppColors.textSecondary,
                            fontWeight: entry.isLate ? FontWeight.w800 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${entry.isPositive ? '+' : '-'} ${MoneyFormatter.format(entry.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: amountColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TimelineFilterChip extends StatelessWidget {
  const _TimelineFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: active ? AppColors.darkNavy : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? AppColors.darkNavy : AppColors.stroke,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMini extends StatelessWidget {
  const _SummaryMini({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC8D3FF),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.textPrimary, size: 19),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
