import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  Future<void> _copyReport(BuildContext context) async {
    final controller = PlanoraScope.of(context);
    final report = controller.monthlyReportText();
    final lang = controller.appLanguageCode;

    await Clipboard.setData(
      ClipboardData(text: report),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_monthlyReportText(lang, 'copied'))),
    );
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
                        _monthlyReportText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _monthlyReportSubtitle(lang, _monthlyReportMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  borderColor: controller.budgetHealthColor.withOpacity(0.30),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: controller.budgetHealthColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            '${controller.budgetHealthScore}',
                            style: TextStyle(
                              color: controller.budgetHealthColor,
                              fontSize: 22,
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
                              controller.budgetHealthLabel,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: controller.budgetHealthColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.budgetHealthMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ReportMetricCard(
                        label: _monthlyReportText(lang, 'income'),
                        value: MoneyFormatter.format(controller.totalMonthlyIncome),
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportMetricCard(
                        label: _monthlyReportText(lang, 'freeBalance'),
                        value: MoneyFormatter.format(controller.freeBalance),
                        icon: Icons.savings_rounded,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                PremiumCard(
                  color: const Color(0xFFF4FFFB),
                  borderColor: AppColors.brandGreen.withOpacity(0.22),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.add_chart_rounded, color: AppColors.brandGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _incomeBreakdownText(lang, MoneyFormatter.format(controller.monthlyIncome), MoneyFormatter.format(controller.extraIncomeTotal)),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ReportMetricCard(
                        label: _monthlyReportText(lang, 'payments'),
                        value: MoneyFormatter.format(controller.plannedPayments),
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportMetricCard(
                        label: _monthlyReportText(lang, 'expenses'),
                        value: MoneyFormatter.format(controller.expensesTotal),
                        icon: Icons.shopping_bag_rounded,
                        color: AppColors.danger,
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
                        title: _monthlyReportText(lang, 'paymentSummary'),
                        actionLabel: '${(controller.paidProgressRatio * 100).round()}%',
                      ),
                      const SizedBox(height: 10),
                      ProgressLine(value: controller.paidProgressRatio),
                      const SizedBox(height: 16),
                      _ReportRow(
                        label: _monthlyReportText(lang, 'paid'),
                        value: _paymentSummaryValue(lang, MoneyFormatter.format(controller.paidPaymentsTotal), controller.paidPaymentCount),
                        color: AppColors.brandGreen,
                      ),
                      const SizedBox(height: 10),
                      _ReportRow(
                        label: _monthlyReportText(lang, 'waiting'),
                        value: _paymentSummaryValue(lang, MoneyFormatter.format(controller.waitingPaymentsTotal), controller.waitingPaymentCount),
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 10),
                      _ReportRow(
                        label: _monthlyReportText(lang, 'late'),
                        value: _paymentSummaryValue(lang, MoneyFormatter.format(controller.latePaymentsTotal), controller.latePaymentCount),
                        color: AppColors.danger,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _monthlyReportText(lang, 'categorySummary')),
                const SizedBox(height: 12),
                if (controller.categorySummary.isEmpty)
                  PremiumCard(
                    child: Text(
                      _monthlyReportText(lang, 'noCategoryData'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...controller.categorySummary.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.folder_rounded, color: category.color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.categoryLabel(category.title),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  '${(category.ratio * 100).round()}%',
                                  style: TextStyle(
                                    color: category.used > category.limit
                                        ? AppColors.danger
                                        : category.ratio >= 0.85
                                            ? AppColors.warning
                                            : AppColors.brandGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ProgressLine(value: category.ratio.clamp(0.0, 1.0)),
                            const SizedBox(height: 8),
                            Text(
                              '${MoneyFormatter.format(category.used)} / ${MoneyFormatter.format(category.limit)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: _monthlyReportText(lang, 'recommendations')),
                      const SizedBox(height: 12),
                      ...controller.budgetHealthTips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: controller.budgetHealthColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Material(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _copyReport(context),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _monthlyReportText(lang, 'copyReport'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
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



String _monthlyReportMonthYearLabel(String code, DateTime month) {
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

String _monthlyReportText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'copied': {
      'tr': 'Aylık rapor panoya kopyalandı.',
      'en': 'Monthly report copied to clipboard.',
      'ru': 'Месячный отчёт скопирован в буфер обмена.',
    },
    'title': {
      'tr': 'Aylık rapor',
      'en': 'Monthly report',
      'ru': 'Месячный отчёт',
    },
    'income': {
      'tr': 'Gelir',
      'en': 'Income',
      'ru': 'Доход',
    },
    'freeBalance': {
      'tr': 'Serbest bakiye',
      'en': 'Free balance',
      'ru': 'Свободный баланс',
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
    'paymentSummary': {
      'tr': 'Ödeme özeti',
      'en': 'Payment summary',
      'ru': 'Сводка платежей',
    },
    'paid': {
      'tr': 'Ödendi',
      'en': 'Paid',
      'ru': 'Оплачено',
    },
    'waiting': {
      'tr': 'Bekliyor',
      'en': 'Waiting',
      'ru': 'Ожидает',
    },
    'late': {
      'tr': 'Gecikti',
      'en': 'Late',
      'ru': 'Просрочено',
    },
    'categorySummary': {
      'tr': 'Kategori özeti',
      'en': 'Category summary',
      'ru': 'Сводка по категориям',
    },
    'noCategoryData': {
      'tr': 'Kategori verisi yok.',
      'en': 'No category data.',
      'ru': 'Нет данных по категориям.',
    },
    'recommendations': {
      'tr': 'Öneriler',
      'en': 'Recommendations',
      'ru': 'Рекомендации',
    },
    'copyReport': {
      'tr': 'Raporu Kopyala',
      'en': 'Copy Report',
      'ru': 'Скопировать отчёт',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _monthlyReportSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return '$month finance summary';
    case 'ru':
      return 'Финансовая сводка за $month';
    case 'tr':
    default:
      return '$month finans özeti';
  }
}

String _paymentSummaryValue(String code, String amount, int count) {
  switch (code) {
    case 'en':
      return '$amount · $count payments';
    case 'ru':
      return '$amount · $count платежей';
    case 'tr':
    default:
      return '$amount · $count ödeme';
  }
}


String _incomeBreakdownText(String code, String fixedIncome, String extraIncome) {
  switch (code) {
    case 'en':
      return 'Fixed income $fixedIncome · Extra income $extraIncome';
    case 'ru':
      return 'Основной доход $fixedIncome · Доп. доход $extraIncome';
    case 'tr':
    default:
      return 'Sabit gelir $fixedIncome · Ek gelir $extraIncome';
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
