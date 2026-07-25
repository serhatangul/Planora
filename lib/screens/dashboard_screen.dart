import 'package:flutter/material.dart';

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
import 'income_settings_screen.dart';
import 'notifications_screen.dart';
import 'monthly_timeline_screen.dart';
import 'month_comparison_screen.dart';
import 'payments_screen.dart';
import 'analysis_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openIncomeSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const IncomeSettingsScreen(),
        ),
      ),
    );
  }

  void _openMonthComparison(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const MonthComparisonScreen(),
        ),
      ),
    );
  }

  void _openTimelineScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const MonthlyTimelineScreen(),
        ),
      ),
    );
  }

  void _openExtraIncomeScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const ExtraIncomeScreen(),
        ),
      ),
    );
  }

  void _openExpensesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const ExpensesScreen(),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const NotificationsScreen(),
        ),
      ),
    );
  }


  void _openPaymentsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const PaymentsScreen(),
        ),
      ),
    );
  }

  void _openAnalysisScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const AnalysisScreen(),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final plannedRatio = controller.monthlyIncome <= 0
            ? 0.0
            : controller.plannedPayments / controller.monthlyIncome;
        final savingRatio = controller.savingTarget <= 0
            ? 0.0
            : controller.currentSaving / controller.savingTarget;
        final nextPayment = controller.nextPayment;
        final alertCount = controller.activeAlertCount;
        final lang = controller.appLanguageCode;
        final smartLimitAlerts = controller.smartLimitAlerts;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 132),
            children: [
              Row(
                children: [
                  const PlanoraLogo(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dashboardText(lang, 'monthUnderControl', month: _dashboardMonthYearLabel(lang, controller.selectedMonth)),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  _IconChip(
                    icon: Icons.notifications_none_rounded,
                    badgeCount: alertCount,
                    onTap: () => _openNotifications(context),
                  ),
                ],
              ),
              if (alertCount > 0) ...[
                const SizedBox(height: 18),
                _AlertSummaryCard(
                  lang: lang,
                  alertCount: alertCount,
                  onTap: () => _openNotifications(context),
                ),
              ],
              if (smartLimitAlerts.isNotEmpty) ...[
                const SizedBox(height: 18),
                _SmartLimitDashboardCard(
                  title: _dashboardText(lang, 'smartLimitAlerts'),
                  alert: smartLimitAlerts.first,
                  actionLabel: _dashboardText(lang, 'viewInAnalysis'),
                  onViewAnalysis: () => _openAnalysisScreen(context),
                ),
              ],
              if (controller.payments.isEmpty && controller.expenseCount == 0) ...[
                const SizedBox(height: 24),
                _StartGuideCard(
                  lang: lang,
                  hasIncome: controller.monthlyIncome > 0,
                  hasSalaryDay: controller.salaryDay > 0,
                  hasPayment: controller.payments.isNotEmpty,
                  hasExpense: controller.expenseCount > 0,
                  onIncomeTap: () => _openIncomeSettings(context),
                  onPaymentTap: () => _openPaymentsScreen(context),
                  onExpenseTap: () => _openExpensesScreen(context),
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _openIncomeSettings(context),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppGradients.premiumDark,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkNavy.withOpacity(0.24),
                        blurRadius: 34,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _dashboardText(lang, 'monthlyIncome'),
                            style: TextStyle(
                              color: Color(0xFFC8D3FF),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.edit_rounded, color: Colors.white70, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        MoneyFormatter.format(controller.totalMonthlyIncome),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ProgressLine(value: plannedRatio),
                      const SizedBox(height: 14),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _incomeBreakdownText(
                                lang,
                                MoneyFormatter.format(controller.monthlyIncome),
                                MoneyFormatter.format(controller.extraIncomeTotal),
                              ),
                              style: const TextStyle(
                                color: Color(0xFFC8D3FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _remainingText(lang, MoneyFormatter.format(controller.remainingAfterPlan)),
                              style: const TextStyle(
                                color: Color(0xFF9FFFE0),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              PremiumCard(
                borderColor: controller.budgetHealthColor.withOpacity(0.30),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: controller.budgetHealthColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          '${controller.budgetHealthScore}',
                          style: TextStyle(
                            color: controller.budgetHealthColor,
                            fontSize: 20,
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
                            _dashboardBudgetHealthTitle(lang, controller.budgetHealthScore),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _dashboardBudgetHealthMessage(lang, controller.budgetHealthScore),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),



              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ShortcutTile(
                      title: _dashboardText(lang, 'compareMonth'),
                      subtitle: _dashboardText(lang, 'compareMonthSubtitle'),
                      icon: Icons.compare_arrows_rounded,
                      onTap: () => _openMonthComparison(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutTile(
                      title: _dashboardText(lang, 'timeline'),
                      subtitle: _dashboardText(lang, 'timelineSubtitle'),
                      icon: Icons.timeline_rounded,
                      onTap: () => _openTimelineScreen(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: _dashboardText(lang, 'nextPayment'),
                      value: nextPayment?.title ?? _dashboardText(lang, 'none'),
                      footer: nextPayment == null
                          ? _dashboardText(lang, 'noPaymentThisMonth')
                          : _paymentDueText(lang, nextPayment.dueDay, MoneyFormatter.format(nextPayment.amount)),
                      footerColor: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetricCard(
                      label: _dashboardText(lang, 'freeBalance'),
                      value: MoneyFormatter.format(controller.freeBalance),
                      footer: _dashboardText(lang, 'availableThisMonth'),
                      footerColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: _dashboardText(lang, 'savingGoal')),
                    const SizedBox(height: 4),
                    Text(
                      '${MoneyFormatter.format(controller.currentSaving)} / ${MoneyFormatter.format(controller.savingTarget)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    ProgressLine(value: savingRatio),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PremiumCard(
                color: const Color(0xFFF9FBFF),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFF6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _salaryTipText(lang, controller.daysUntilNextSalary, MoneyFormatter.format(controller.dailySafeLimit)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),



              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TrackingTile(
                      label: _dashboardText(lang, 'extraIncome'),
                      value: MoneyFormatter.format(controller.extraIncomeTotal),
                      count: controller.extraIncomeCount,
                      countLabel: _recordCountText(lang, controller.extraIncomeCount),
                      icon: Icons.add_chart_rounded,
                      color: AppColors.brandGreen,
                      backgroundColor: const Color(0xFFF4FFFB),
                      onTap: () => _openExtraIncomeScreen(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrackingTile(
                      label: _dashboardText(lang, 'spent'),
                      value: MoneyFormatter.format(controller.expensesTotal),
                      count: controller.expenseCount,
                      countLabel: _recordCountText(lang, controller.expenseCount),
                      icon: Icons.shopping_bag_rounded,
                      color: AppColors.warning,
                      backgroundColor: const Color(0xFFFFFBF4),
                      onTap: () => _openExpensesScreen(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dashboardText(lang, 'paymentSummary'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${(controller.paidProgressRatio * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.brandBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProgressLine(value: controller.paidProgressRatio),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallSummaryItem(
                            label: _dashboardText(lang, 'paid'),
                            value: MoneyFormatter.format(controller.paidPaymentsTotal),
                            count: controller.paidPaymentCount,
                            countLabel: _paymentCountText(lang, controller.paidPaymentCount),
                            color: AppColors.brandGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallSummaryItem(
                            label: _dashboardText(lang, 'waiting'),
                            value: MoneyFormatter.format(controller.waitingPaymentsTotal),
                            count: controller.waitingPaymentCount,
                            countLabel: _paymentCountText(lang, controller.waitingPaymentCount),
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallSummaryItem(
                            label: _dashboardText(lang, 'late'),
                            value: MoneyFormatter.format(controller.latePaymentsTotal),
                            count: controller.latePaymentCount,
                            countLabel: _paymentCountText(lang, controller.latePaymentCount),
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SectionHeader(
                title: _dashboardText(lang, 'thisMonthPayments'),
                actionLabel: _dashboardText(lang, 'all'),
                onActionTap: () => _openPaymentsScreen(context),
              ),
              const SizedBox(height: 12),
              if (controller.paymentsForSelectedMonth.isEmpty)
                PlanoraEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: _dashboardText(lang, 'noPaymentsTitle'),
                  description: _dashboardText(lang, 'noPaymentsDescription'),
                  actionLabel: _dashboardText(lang, 'addPayment'),
                  onActionTap: () => _openPaymentsScreen(context),
                  color: AppColors.brandBlue,
                )
              else
                ...controller.paymentsForSelectedMonth.take(5).map(
                      (payment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PaymentListItem(
                          payment: payment,
                          isLate: controller.isPaymentLate(payment),
                          onTap: () => _openPaymentEdit(context, payment.id),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}






String _startGuideText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Başlangıç rehberi',
      'en': 'Getting started',
      'ru': 'Начало работы',
    },
    'subtitle': {
      'tr': 'Planora’yı doğru kullanmak için bu adımları tamamla.',
      'en': 'Complete these steps to set up Planora properly.',
      'ru': 'Выполните эти шаги, чтобы правильно настроить Planora.',
    },
    'income': {
      'tr': 'Aylık gelirini ekle',
      'en': 'Add monthly income',
      'ru': 'Добавьте месячный доход',
    },
    'incomeSubtitle': {
      'tr': 'Bütçe hesabının temelini oluşturur.',
      'en': 'This is the base of your budget calculation.',
      'ru': 'Это основа расчёта вашего бюджета.',
    },
    'salaryDay': {
      'tr': 'Maaş gününü belirle',
      'en': 'Set salary day',
      'ru': 'Укажите день зарплаты',
    },
    'salaryDaySubtitle': {
      'tr': 'Aylık döngü buna göre hesaplanır.',
      'en': 'Your monthly cycle is calculated from this.',
      'ru': 'Месячный цикл будет рассчитываться от этой даты.',
    },
    'payment': {
      'tr': 'İlk sabit ödemeni ekle',
      'en': 'Add first fixed payment',
      'ru': 'Добавьте первый регулярный платёж',
    },
    'paymentSubtitle': {
      'tr': 'Kira, fatura veya abonelik gibi.',
      'en': 'For rent, bills, subscriptions, and more.',
      'ru': 'Например аренда, счета или подписки.',
    },
    'expense': {
      'tr': 'İlk harcamanı kaydet',
      'en': 'Record first expense',
      'ru': 'Запишите первый расход',
    },
    'expenseSubtitle': {
      'tr': 'Günlük harcamaları takip etmeye başla.',
      'en': 'Start tracking daily spending.',
      'ru': 'Начните отслеживать ежедневные расходы.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _dashboardBudgetHealthLabel(String code, int score) {
  if (score >= 80) {
    switch (code) {
      case 'en':
        return 'Healthy';
      case 'ru':
        return 'Здоровый';
      case 'tr':
      default:
        return 'Sağlıklı';
    }
  }

  if (score >= 60) {
    switch (code) {
      case 'en':
        return 'Careful';
      case 'ru':
        return 'Внимание';
      case 'tr':
      default:
        return 'Dikkatli';
    }
  }

  if (score >= 40) {
    switch (code) {
      case 'en':
        return 'Risky';
      case 'ru':
        return 'Риск';
      case 'tr':
      default:
        return 'Riskli';
    }
  }

  switch (code) {
    case 'en':
      return 'Critical';
    case 'ru':
      return 'Критично';
    case 'tr':
    default:
      return 'Kritik';
  }
}

String _dashboardBudgetHealthTitle(String code, int score) {
  final label = _dashboardBudgetHealthLabel(code, score);

  switch (code) {
    case 'en':
      return 'Budget health: $label';
    case 'ru':
      return 'Состояние бюджета: $label';
    case 'tr':
    default:
      return 'Bütçe sağlığı: $label';
  }
}

String _dashboardBudgetHealthMessage(String code, int score) {
  if (score >= 80) {
    switch (code) {
      case 'en':
        return 'Your budget looks balanced this month. Payments and spending limits are under control.';
      case 'ru':
        return 'Ваш бюджет в этом месяце выглядит сбалансированным. Платежи и лимиты расходов под контролем.';
      case 'tr':
      default:
        return 'Bu ay bütçen dengeli görünüyor. Ödemeler ve harcama limitleri kontrol altında.';
    }
  }

  if (score >= 60) {
    switch (code) {
      case 'en':
        return 'Your budget is generally good, but some areas need attention.';
      case 'ru':
        return 'В целом бюджет в порядке, но некоторые области требуют внимания.';
      case 'tr':
      default:
        return 'Bütçen genel olarak iyi ama bazı alanlarda dikkatli olman gerekiyor.';
    }
  }

  if (score >= 40) {
    switch (code) {
      case 'en':
        return 'Risk is starting to appear in your budget this month. Reducing waiting payments and expenses would help.';
      case 'ru':
        return 'В бюджете этого месяца начинает появляться риск. Лучше сократить ожидающие платежи и расходы.';
      case 'tr':
      default:
        return 'Bu ay bütçende risk oluşmaya başladı. Bekleyen ödemeleri ve harcamaları azaltman iyi olur.';
    }
  }

  switch (code) {
    case 'en':
      return 'Your budget is at a critical level this month. Late payments, exceeded limits, or free balance are under serious pressure.';
    case 'ru':
      return 'Бюджет в этом месяце на критическом уровне. Просрочки, превышение лимитов или свободный баланс находятся под серьёзным давлением.';
    case 'tr':
    default:
      return 'Bu ay bütçen kritik seviyede. Geciken ödemeler, limit aşımları veya serbest bakiye ciddi şekilde zorlanıyor.';
  }
}

String _dashboardMonthYearLabel(String code, DateTime month) {
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

String _dashboardText(String code, String key, {String? month}) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'monthUnderControl': {
      'tr': '{month} planın kontrol altında.',
      'en': '{month} plan is under control.',
      'ru': 'План на {month} под контролем.',
    },
    'smartLimitAlerts': {
      'tr': 'Akıllı limit uyarısı',
      'en': 'Smart limit alert',
      'ru': 'Умное уведомление о лимите',
    },
    'viewInAnalysis': {
      'tr': 'Analizde Gör',
      'en': 'View in Analysis',
      'ru': 'Смотреть в анализе',
    },
    'monthlyIncome': {
      'tr': 'Aylık Kazancın',
      'en': 'Monthly Income',
      'ru': 'Месячный доход',
    },
    'compareMonth': {
      'tr': 'Ay karşılaştır',
      'en': 'Compare month',
      'ru': 'Сравнить месяц',
    },
    'compareMonthSubtitle': {
      'tr': 'Geçen ayla kıyasla',
      'en': 'Compare with last month',
      'ru': 'Сравнить с прошлым месяцем',
    },
    'timeline': {
      'tr': 'Akış',
      'en': 'Timeline',
      'ru': 'Лента',
    },
    'timelineSubtitle': {
      'tr': 'Gün gün takip et',
      'en': 'Track day by day',
      'ru': 'Отслеживать по дням',
    },
    'nextPayment': {
      'tr': 'Yaklaşan ödeme',
      'en': 'Next payment',
      'ru': 'Ближайший платёж',
    },
    'none': {
      'tr': 'Yok',
      'en': 'None',
      'ru': 'Нет',
    },
    'noPaymentThisMonth': {
      'tr': 'Bu ay ödeme yok',
      'en': 'No payment this month',
      'ru': 'В этом месяце платежей нет',
    },
    'freeBalance': {
      'tr': 'Serbest bakiye',
      'en': 'Free balance',
      'ru': 'Свободный баланс',
    },
    'availableThisMonth': {
      'tr': 'Bu ay kullanılabilir',
      'en': 'Available this month',
      'ru': 'Доступно в этом месяце',
    },
    'savingGoal': {
      'tr': 'Birikim Hedefi',
      'en': 'Saving Goal',
      'ru': 'Цель накопления',
    },
    'extraIncome': {
      'tr': 'Ek gelir',
      'en': 'Extra income',
      'ru': 'Доп. доход',
    },
    'spent': {
      'tr': 'Harcama',
      'en': 'Expenses',
      'ru': 'Расходы',
    },
    'paymentSummary': {
      'tr': 'Aylık ödeme özeti',
      'en': 'Monthly payment summary',
      'ru': 'Сводка платежей за месяц',
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
    'thisMonthPayments': {
      'tr': 'Bu ayki ödemeler',
      'en': 'This month’s payments',
      'ru': 'Платежи этого месяца',
    },
    'all': {
      'tr': 'Tümü',
      'en': 'All',
      'ru': 'Все',
    },
    'noPaymentsTitle': {
      'tr': 'Bu ay için ödeme yok',
      'en': 'No payments for this month',
      'ru': 'Нет платежей за этот месяц',
    },
    'noPaymentsDescription': {
      'tr': 'Aylık veya tek seferlik ödemelerini eklediğinde ana ekranda hızlıca takip edebilirsin.',
      'en': 'Add monthly or one-time payments to track them quickly on the dashboard.',
      'ru': 'Добавьте ежемесячные или разовые платежи, чтобы быстро отслеживать их на главном экране.',
    },
    'addPayment': {
      'tr': 'Ödeme Ekle',
      'en': 'Add Payment',
      'ru': 'Добавить платёж',
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
  };

  final text = values[key]?[language] ?? values[key]?['tr'] ?? key;
  return month == null ? text : text.replaceAll('{month}', month);
}

String _incomeBreakdownText(String code, String fixedIncome, String extraIncome) {
  switch (code) {
    case 'en':
      return 'Fixed: $fixedIncome · Extra: $extraIncome';
    case 'ru':
      return 'Основной: $fixedIncome · Доп.: $extraIncome';
    case 'tr':
    default:
      return 'Sabit: $fixedIncome · Ek: $extraIncome';
  }
}

String _remainingText(String code, String amount) {
  switch (code) {
    case 'en':
      return 'Remaining: $amount';
    case 'ru':
      return 'Осталось: $amount';
    case 'tr':
    default:
      return 'Kalan: $amount';
  }
}

String _budgetHealthTitle(String code, String label) {
  switch (code) {
    case 'en':
      return 'Budget health: $label';
    case 'ru':
      return 'Состояние бюджета: $label';
    case 'tr':
    default:
      return 'Bütçe sağlığı: $label';
  }
}

String _paymentDueText(String code, int day, String amount) {
  switch (code) {
    case 'en':
      return 'Day $day · $amount';
    case 'ru':
      return '$day-й день · $amount';
    case 'tr':
    default:
      return '$day. gün · $amount';
  }
}

String _salaryTipText(String code, int days, String amount) {
  switch (code) {
    case 'en':
      return '$days days left until the next salary. Your daily safe limit is $amount.';
    case 'ru':
      return 'До следующей зарплаты осталось $days дн. Дневной безопасный лимит: $amount.';
    case 'tr':
    default:
      return 'Bir sonraki maaşa $days gün kaldı. Günlük güvenli limitin $amount.';
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

String _paymentCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count payments';
    case 'ru':
      return '$count платежей';
    case 'tr':
    default:
      return '$count ödeme';
  }
}

String _alertText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count active alerts. Tap to review.';
    case 'ru':
      return '$count активных уведомлений. Нажмите для проверки.';
    case 'tr':
    default:
      return '$count aktif uyarı var. Kontrol etmek için dokun.';
  }
}

String _latePaymentText(String code, int day) {
  switch (code) {
    case 'en':
      return 'Day $day · late';
    case 'ru':
      return '$day-й день · просрочено';
    case 'tr':
    default:
      return '$day. gün · gecikti';
  }
}

String _paymentCategoryText(String code, int day, String category) {
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


class _StartGuideCard extends StatelessWidget {
  const _StartGuideCard({
    required this.lang,
    required this.hasIncome,
    required this.hasSalaryDay,
    required this.hasPayment,
    required this.hasExpense,
    required this.onIncomeTap,
    required this.onPaymentTap,
    required this.onExpenseTap,
  });

  final String lang;
  final bool hasIncome;
  final bool hasSalaryDay;
  final bool hasPayment;
  final bool hasExpense;
  final VoidCallback onIncomeTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onExpenseTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      color: const Color(0xFFF7FAFF),
      borderColor: AppColors.brandBlue.withOpacity(0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _startGuideText(lang, 'title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _startGuideText(lang, 'subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StartGuideStep(
            title: _startGuideText(lang, 'income'),
            subtitle: _startGuideText(lang, 'incomeSubtitle'),
            isDone: hasIncome,
            onTap: onIncomeTap,
          ),
          const SizedBox(height: 10),
          _StartGuideStep(
            title: _startGuideText(lang, 'salaryDay'),
            subtitle: _startGuideText(lang, 'salaryDaySubtitle'),
            isDone: hasSalaryDay,
            onTap: onIncomeTap,
          ),
          const SizedBox(height: 10),
          _StartGuideStep(
            title: _startGuideText(lang, 'payment'),
            subtitle: _startGuideText(lang, 'paymentSubtitle'),
            isDone: hasPayment,
            onTap: onPaymentTap,
          ),
          const SizedBox(height: 10),
          _StartGuideStep(
            title: _startGuideText(lang, 'expense'),
            subtitle: _startGuideText(lang, 'expenseSubtitle'),
            isDone: hasExpense,
            onTap: onExpenseTap,
          ),
        ],
      ),
    );
  }
}

class _StartGuideStep extends StatelessWidget {
  const _StartGuideStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDone
                ? AppColors.brandGreen.withOpacity(0.28)
                : AppColors.textSecondary.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.brandGreen.withOpacity(0.12)
                    : AppColors.brandBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: isDone ? AppColors.brandGreen : AppColors.brandBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      color: const Color(0xFFF9FBFF),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.brandBlue, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TrackingTile extends StatelessWidget {
  const _TrackingTile({
    required this.label,
    required this.value,
    required this.count,
    required this.countLabel,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final int count;
  final String countLabel;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      color: backgroundColor,
      borderColor: color.withOpacity(0.22),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            countLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}


class _SmartLimitDashboardCard extends StatelessWidget {
  const _SmartLimitDashboardCard({
    required this.title,
    required this.alert,
    required this.actionLabel,
    required this.onViewAnalysis,
  });

  final String title;
  final SmartLimitAlert alert;
  final String actionLabel;
  final VoidCallback onViewAnalysis;

  @override
  Widget build(BuildContext context) {
    final alertColor = alert.isExceeded ? AppColors.danger : AppColors.warning;

    return PremiumCard(
      color: alert.isExceeded ? const Color(0xFFFFF5F5) : const Color(0xFFFFFBF4),
      borderColor: alertColor.withOpacity(0.28),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  alert.isExceeded ? Icons.error_rounded : Icons.warning_amber_rounded,
                  color: alertColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: alertColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(alert.message, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    ProgressLine(
                      value: alert.ratio.clamp(0, 1),
                      gradient: LinearGradient(colors: [alertColor, alertColor]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: alertColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onViewAnalysis,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_rounded, color: alertColor, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          actionLabel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: alertColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  const _AlertSummaryCard({
    required this.lang,
    required this.alertCount,
    required this.onTap,
  });

  final String lang;
  final int alertCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      color: const Color(0xFFFFFBF4),
      borderColor: AppColors.warning.withOpacity(0.35),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0D3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: AppColors.warning),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _alertText(lang, alertCount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}


class _SmallSummaryItem extends StatelessWidget {
  const _SmallSummaryItem({
    required this.label,
    required this.value,
    required this.count,
    required this.countLabel,
    required this.color,
  });

  final String label;
  final String value;
  final int count;
  final String countLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              countLabel,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _PaymentListItem extends StatelessWidget {
  const _PaymentListItem({
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

    return PremiumCard(
      borderColor: isLate ? AppColors.danger.withOpacity(0.45) : AppColors.stroke,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: payment.color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_rounded : Icons.payments_rounded,
                    color: payment.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: isPaid ? TextDecoration.lineThrough : null,
                              color: isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isLate
                            ? _latePaymentText(controller.appLanguageCode, payment.dueDay)
                            : _paymentCategoryText(controller.appLanguageCode, payment.dueDay, controller.categoryLabel(payment.category)),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isLate ? AppColors.danger : AppColors.textSecondary,
                              fontWeight: isLate ? FontWeight.w800 : FontWeight.w500,
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
    final lang = PlanoraScope.of(context).appLanguageCode;
    final backgroundColor = isPaid ? const Color(0xFFE8FFF6) : const Color(0xFFFFF6E5);
    final textColor = isPaid ? const Color(0xFF0A7A59) : AppColors.warning;
    final icon = isPaid ? Icons.undo_rounded : Icons.check_circle_rounded;
    final label = isPaid ? _dashboardText(lang, 'markWaiting') : _dashboardText(lang, 'markPaid');

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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.footer,
    required this.footerColor,
  });

  final String label;
  final String value;
  final String footer;
  final Color footerColor;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 6),
            Text(
              footer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: footerColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.onTap,
    required this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
