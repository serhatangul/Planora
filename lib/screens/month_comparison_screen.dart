import 'package:flutter/material.dart';

import '../models/expense_item.dart';
import '../models/income_item.dart';
import '../models/payment_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class _MonthSnapshot {
  const _MonthSnapshot({
    required this.month,
    required this.income,
    required this.extraIncome,
    required this.totalIncome,
    required this.payments,
    required this.paidPayments,
    required this.waitingPayments,
    required this.latePayments,
    required this.expenses,
    required this.freeBalance,
    required this.healthScore,
  });

  final DateTime month;
  final double income;
  final double extraIncome;
  final double totalIncome;
  final double payments;
  final double paidPayments;
  final double waitingPayments;
  final double latePayments;
  final double expenses;
  final double freeBalance;
  final int healthScore;
}

class MonthComparisonScreen extends StatefulWidget {
  const MonthComparisonScreen({super.key});

  @override
  State<MonthComparisonScreen> createState() => _MonthComparisonScreenState();
}

class _MonthComparisonScreenState extends State<MonthComparisonScreen> {
  DateTime? _leftMonth;
  DateTime? _rightMonth;

  DateTime _monthOnly(DateTime value) {
    return DateTime(value.year, value.month, 1);
  }

  DateTime _shiftMonth(DateTime value, int delta) {
    return DateTime(value.year, value.month + delta, 1);
  }

  bool _canMoveForward(DateTime value) {
    final current = _monthOnly(DateTime.now());
    final next = _shiftMonth(value, 1);
    return !next.isAfter(current);
  }

  Widget _monthSelector(
    BuildContext context, {
    required DateTime month,
    required String lang,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
    required bool canMoveForward,
    required ValueChanged<DateTime> onSelected,
  }) {
    return Expanded(
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final selected = await _showMonthYearPicker(
                    context,
                    initialMonth: month,
                    lang: lang,
                  );

                  if (selected != null) {
                    onSelected(selected);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        PlanoraDateUtils.monthYearLabel(
                          month,
                          languageCode: lang,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: canMoveForward ? onNext : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showMonthYearPicker(
    BuildContext context, {
    required DateTime initialMonth,
    required String lang,
  }) async {
    int selectedMonth = initialMonth.month;
    int selectedYear = initialMonth.year;

    final now = DateTime.now();
    final years = List<int>.generate(
      21,
      (index) => now.year - 20 + index,
    );

    String text(String tr, String en, String ru) {
      switch (lang) {
        case 'en':
          return en;
        case 'ru':
          return ru;
        default:
          return tr;
      }
    }

    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final monthNames = PlanoraDateUtils.monthNamesFor(lang);

            return AlertDialog(
              title: Text(
                text(
                  'Ay ve yıl seç',
                  'Select month and year',
                  'Выберите месяц и год',
                ),
              ),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: text('Ay', 'Month', 'Месяц'),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(monthNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: text('Yıl', 'Year', 'Год'),
                      ),
                      items: years
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    text('Vazgeç', 'Cancel', 'Отмена'),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final selected = DateTime(selectedYear, selectedMonth, 1);

                    if (selected.isAfter(
                      DateTime(now.year, now.month, 1),
                    )) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(selected);
                  },
                  child: Text(
                    text('Seç', 'Select', 'Выбрать'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _monthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  bool _isPaymentVisible(PaymentItem payment, DateTime month) {
    if (payment.isMonthly) return true;

    final key = payment.monthKey;
    if (key == null || key.isEmpty) return true;

    return key == _monthKey(month);
  }

  bool _isLateInMonth(
      PlanoraController controller, PaymentItem payment, DateTime month) {
    final now = DateTime.now();

    if (!PlanoraDateUtils.isSameMonth(now, month)) {
      return false;
    }

    return !controller.isPaymentPaid(payment, month: month) &&
        payment.dueDay < now.day;
  }

  _MonthSnapshot _snapshotFor(PlanoraController controller, DateTime month) {
    final key = _monthKey(month);
    final days = PlanoraDateUtils.daysInMonth(month);

    final payments = controller.payments
        .where((payment) => payment.dueDay <= days)
        .where((payment) => _isPaymentVisible(payment, month))
        .toList();

    final expenses = controller.expenses
        .where((expense) => expense.monthKey == key)
        .toList();

    final incomes = controller.extraIncomes
        .where((income) => income.monthKey == key)
        .toList();

    final paidPayments = payments
        .where((payment) => controller.isPaymentPaid(payment, month: month))
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    final latePayments = payments
        .where((payment) => _isLateInMonth(controller, payment, month))
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    final waitingPayments = payments
        .where((payment) => !controller.isPaymentPaid(payment, month: month))
        .where((payment) => !_isLateInMonth(controller, payment, month))
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    final paymentTotal =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final expenseTotal =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final extraIncomeTotal =
        incomes.fold<double>(0, (sum, income) => sum + income.amount);

    final totalIncome = controller.monthlyIncome + extraIncomeTotal;
    final freeBalance =
        (totalIncome - paymentTotal - expenseTotal - controller.currentSaving)
            .clamp(0.0, double.infinity);

    var score = 100;
    final incomeBase = totalIncome <= 0 ? 1 : totalIncome;

    final plannedRatio = paymentTotal / incomeBase;
    if (plannedRatio > 0.85) {
      score -= 18;
    } else if (plannedRatio > 0.70) {
      score -= 10;
    }

    final expenseRatio = expenseTotal / incomeBase;
    if (expenseRatio > 0.25) {
      score -= 16;
    } else if (expenseRatio > 0.15) {
      score -= 8;
    }

    if (latePayments > 0) score -= 10;
    if (freeBalance <= 0) score -= 18;
    if (paidPayments >= paymentTotal * 0.75 &&
        latePayments == 0 &&
        paymentTotal > 0) {
      score += 6;
    }

    return _MonthSnapshot(
      month: month,
      income: controller.monthlyIncome,
      extraIncome: extraIncomeTotal,
      totalIncome: totalIncome,
      payments: paymentTotal,
      paidPayments: paidPayments,
      waitingPayments: waitingPayments,
      latePayments: latePayments,
      expenses: expenseTotal,
      freeBalance: freeBalance,
      healthScore: score.clamp(0, 100),
    );
  }

  String _trendText(
      String lang, _MonthSnapshot current, _MonthSnapshot previous) {
    final scoreDiff = current.healthScore - previous.healthScore;
    final freeDiff = current.freeBalance - previous.freeBalance;
    final expenseDiff = current.expenses - previous.expenses;

    if (scoreDiff >= 8 && freeDiff >= 0) {
      return _monthComparisonText(lang, 'trendHealthy');
    }

    if (scoreDiff <= -8 || expenseDiff > previous.expenses * 0.20) {
      return _monthComparisonText(lang, 'trendRisky');
    }

    if (freeDiff > 0) {
      return _monthComparisonText(lang, 'trendFreeBalanceBetter');
    }

    return _monthComparisonText(lang, 'trendStable');
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final lang = controller.appLanguageCode;

            _rightMonth ??= _monthOnly(controller.selectedMonth);
            _leftMonth ??= _shiftMonth(_rightMonth!, -1);

            final currentMonth = _rightMonth!;
            final previousMonth = _leftMonth!;

            final current = _snapshotFor(controller, currentMonth);
            final previous = _snapshotFor(controller, previousMonth);

            final incomeDiff = current.totalIncome - previous.totalIncome;
            final paymentDiff = current.payments - previous.payments;
            final expenseDiff = current.expenses - previous.expenses;
            final freeDiff = current.freeBalance - previous.freeBalance;
            final scoreDiff = current.healthScore - previous.healthScore;

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
                        _monthComparisonText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${PlanoraDateUtils.monthYearLabel(previousMonth, languageCode: lang)} / ${PlanoraDateUtils.monthYearLabel(currentMonth, languageCode: lang)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _monthSelector(
                      context,
                      month: previousMonth,
                      lang: lang,
                      onPrevious: () {
                        setState(() {
                          _leftMonth = _shiftMonth(previousMonth, -1);
                        });
                      },
                      onNext: () {
                        setState(() {
                          _leftMonth = _shiftMonth(previousMonth, 1);
                        });
                      },
                      canMoveForward: _canMoveForward(previousMonth),
                      onSelected: (selected) {
                        setState(() {
                          _leftMonth = selected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _monthSelector(
                      context,
                      month: currentMonth,
                      lang: lang,
                      onPrevious: () {
                        setState(() {
                          _rightMonth = _shiftMonth(currentMonth, -1);
                        });
                      },
                      onNext: () {
                        setState(() {
                          _rightMonth = _shiftMonth(currentMonth, 1);
                        });
                      },
                      canMoveForward: _canMoveForward(currentMonth),
                      onSelected: (selected) {
                        setState(() {
                          _rightMonth = selected;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.compare_arrows_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _trendText(lang, current, previous),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreCard(
                        lang: lang,
                        title: PlanoraDateUtils.monthYearLabel(previousMonth,
                            languageCode: lang),
                        score: previous.healthScore,
                        muted: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ScoreCard(
                        lang: lang,
                        title: PlanoraDateUtils.monthYearLabel(currentMonth,
                            languageCode: lang),
                        score: current.healthScore,
                        muted: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: _monthComparisonText(lang, 'differenceSummary'),
                        actionLabel: _scoreDiffText(lang, scoreDiff),
                      ),
                      const SizedBox(height: 14),
                      _ComparisonRow(
                        label: _monthComparisonText(lang, 'totalIncome'),
                        current: current.totalIncome,
                        previous: previous.totalIncome,
                        diff: incomeDiff,
                        positiveIsGood: true,
                      ),
                      const SizedBox(height: 12),
                      _ComparisonRow(
                        label: _monthComparisonText(lang, 'plannedPayment'),
                        current: current.payments,
                        previous: previous.payments,
                        diff: paymentDiff,
                        positiveIsGood: false,
                      ),
                      const SizedBox(height: 12),
                      _ComparisonRow(
                        label: _monthComparisonText(lang, 'variableExpense'),
                        current: current.expenses,
                        previous: previous.expenses,
                        diff: expenseDiff,
                        positiveIsGood: false,
                      ),
                      const SizedBox(height: 12),
                      _ComparisonRow(
                        label: _monthComparisonText(lang, 'freeBalance'),
                        current: current.freeBalance,
                        previous: previous.freeBalance,
                        diff: freeDiff,
                        positiveIsGood: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: _monthComparisonText(lang, 'paidThisMonth'),
                        value: MoneyFormatter.format(current.paidPayments),
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniMetric(
                        label: _monthComparisonText(lang, 'waitingThisMonth'),
                        value: MoneyFormatter.format(current.waitingPayments),
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: _monthComparisonText(lang, 'lateThisMonth'),
                        value: MoneyFormatter.format(current.latePayments),
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniMetric(
                        label: _monthComparisonText(lang, 'extraIncomeDiff'),
                        value: MoneyFormatter.format(
                            current.extraIncome - previous.extraIncome),
                        color: (current.extraIncome - previous.extraIncome) >= 0
                            ? AppColors.brandGreen
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded,
                          color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _monthComparisonText(lang, 'infoNote'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
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

String _monthComparisonText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'trendHealthy': {
      'tr':
          'Bu ay geçen aya göre daha sağlıklı ilerliyor. Serbest bakiye ve bütçe skoru güçlü.',
      'en':
          'This month is progressing healthier than last month. Free balance and budget score are strong.',
      'ru':
          'Этот месяц выглядит здоровее прошлого. Свободный баланс и бюджетный балл сильные.',
    },
    'trendRisky': {
      'tr':
          'Bu ay geçen aya göre daha riskli görünüyor. Harcamalar ve ödeme yükü dikkat istiyor.',
      'en':
          'This month looks riskier than last month. Expenses and payment load need attention.',
      'ru':
          'Этот месяц выглядит рискованнее прошлого. Расходы и платёжная нагрузка требуют внимания.',
    },
    'trendFreeBalanceBetter': {
      'tr':
          'Bu ay serbest bakiye geçen aya göre daha iyi. Plan aynı disiplinle korunabilir.',
      'en':
          'Free balance is better this month than last month. The plan can be maintained with the same discipline.',
      'ru':
          'Свободный баланс в этом месяце лучше, чем в прошлом. План можно сохранить в том же темпе.',
    },
    'trendStable': {
      'tr':
          'Bu ay geçen aya yakın ilerliyor. Büyük bir sapma yok ama harcama temposunu takip etmek iyi olur.',
      'en':
          'This month is close to last month. There is no major deviation, but it is good to watch spending pace.',
      'ru':
          'Этот месяц близок к прошлому. Большого отклонения нет, но стоит следить за темпом расходов.',
    },
    'title': {
      'tr': 'Ay karşılaştırması',
      'en': 'Month comparison',
      'ru': 'Сравнение месяцев'
    },
    'differenceSummary': {
      'tr': 'Fark özeti',
      'en': 'Difference summary',
      'ru': 'Сводка различий'
    },
    'totalIncome': {
      'tr': 'Toplam gelir',
      'en': 'Total income',
      'ru': 'Общий доход'
    },
    'plannedPayment': {
      'tr': 'Planlanan ödeme',
      'en': 'Planned payments',
      'ru': 'Плановые платежи'
    },
    'variableExpense': {
      'tr': 'Değişken harcama',
      'en': 'Variable expenses',
      'ru': 'Переменные расходы'
    },
    'freeBalance': {
      'tr': 'Serbest bakiye',
      'en': 'Free balance',
      'ru': 'Свободный баланс'
    },
    'paidThisMonth': {
      'tr': 'Bu ay ödendi',
      'en': 'Paid this month',
      'ru': 'Оплачено за месяц'
    },
    'waitingThisMonth': {
      'tr': 'Bu ay bekliyor',
      'en': 'Waiting this month',
      'ru': 'Ожидает за месяц'
    },
    'lateThisMonth': {
      'tr': 'Bu ay gecikti',
      'en': 'Late this month',
      'ru': 'Просрочено за месяц'
    },
    'extraIncomeDiff': {
      'tr': 'Ek gelir farkı',
      'en': 'Extra income difference',
      'ru': 'Разница доп. дохода'
    },
    'infoNote': {
      'tr':
          'Karşılaştırma seçili ay ile bir önceki ay arasında yapılır. Tek seferlik ödemeler sadece ait olduğu ayda hesaba katılır.',
      'en':
          'The comparison is made between the selected month and the previous month. One-time payments are counted only in their own month.',
      'ru':
          'Сравнение выполняется между выбранным и предыдущим месяцем. Разовые платежи учитываются только в своём месяце.',
    },
    'budgetScore': {
      'tr': 'Bütçe skoru',
      'en': 'Budget score',
      'ru': 'Бюджетный балл'
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _scoreDiffText(String code, int scoreDiff) {
  final prefix = scoreDiff >= 0 ? '+' : '';

  switch (code) {
    case 'en':
      return '$prefix$scoreDiff points';
    case 'ru':
      return '$prefix$scoreDiff баллов';
    case 'tr':
    default:
      return '$prefix$scoreDiff puan';
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.lang,
    required this.title,
    required this.score,
    required this.muted,
  });

  final String lang;
  final String title;
  final int score;
  final bool muted;

  Color get _scoreColor {
    if (score >= 80) return AppColors.brandGreen;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return const Color(0xFFFF7A1A);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      borderColor: _scoreColor.withOpacity(muted ? 0.12 : 0.30),
      child: SizedBox(
        height: 118,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Text(
              '$score',
              style: TextStyle(
                color: muted ? AppColors.textSecondary : _scoreColor,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _monthComparisonText(lang, 'budgetScore'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.diff,
    required this.positiveIsGood,
  });

  final String label;
  final double current;
  final double previous;
  final double diff;
  final bool positiveIsGood;

  @override
  Widget build(BuildContext context) {
    final isPositive = diff >= 0;
    final isGood = positiveIsGood ? isPositive : !isPositive;
    final color = diff == 0
        ? AppColors.textSecondary
        : isGood
            ? AppColors.brandGreen
            : AppColors.danger;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              MoneyFormatter.format(current),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              '${isPositive ? '+' : '-'}${MoneyFormatter.format(diff.abs())}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 82,
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
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
