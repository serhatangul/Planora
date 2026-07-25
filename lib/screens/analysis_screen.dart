import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/planora_empty_state.dart';
import 'add_payment_screen.dart';
import 'expenses_screen.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lang = controller.appLanguageCode;
        final categories = controller.categorySummary;
        final smartLimitAlerts = controller.smartLimitAlerts;
        final plannedRatio = controller.monthlyIncome <= 0 ? 0.0 : controller.plannedPayments / controller.monthlyIncome;

        return Scaffold(
          backgroundColor: AppColors.softBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 132),
              children: [
              Text(_analysisText(lang, 'title'), style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(_analysisText(lang, 'subtitle'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              PremiumCard(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 238,
                            height: 238,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 30,
                              color: Color(0xFFE9EEF7),
                            ),
                          ),
                          SizedBox(
                            width: 238,
                            height: 238,
                            child: CircularProgressIndicator(
                              value: plannedRatio.clamp(0, 1),
                              strokeWidth: 30,
                              strokeCap: StrokeCap.round,
                              color: AppColors.brandGreen,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  MoneyFormatter.format(controller.plannedPayments),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _analysisText(lang, 'planned'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _monthEndRemainingText(lang, MoneyFormatter.format(controller.freeBalance)),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.brandGreen,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: _analysisText(lang, 'categories')),
              const SizedBox(height: 12),
              if (categories.isEmpty)
                PlanoraEmptyState(
                  icon: Icons.pie_chart_outline_rounded,
                  title: _analysisText(lang, 'emptyAnalysisTitle'),
                  description: _analysisText(lang, 'emptyAnalysisDescription'),
                  actionLabel: _analysisText(lang, 'addPayment'),
                  onActionTap: () => _openPaymentAdd(context),
                  secondaryActionLabel: _analysisText(lang, 'addExpense'),
                  onSecondaryActionTap: () => _openExpenses(context),
                  color: AppColors.brandBlue,
                )
              else
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.categoryLabel(category.title),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '${(category.ratio * 100).round()}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ProgressLine(
                            value: category.ratio.clamp(0, 1),
                            gradient: LinearGradient(colors: [category.color, category.color]),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                MoneyFormatter.format(category.used),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const Spacer(),
                              Text(
                                MoneyFormatter.format(category.limit),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SectionHeader(title: _analysisText(lang, 'smartLimitAlerts')),
              const SizedBox(height: 12),
              if (smartLimitAlerts.isEmpty)
                _SmartLimitEmptyCard(
                  message: _analysisText(lang, 'noSmartLimitAlerts'),
                )
              else
                ...smartLimitAlerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SmartLimitAnalysisCard(alert: alert),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SmartLimitAnalysisCard extends StatelessWidget {
  const _SmartLimitAnalysisCard({required this.alert});

  final SmartLimitAlert alert;

  @override
  Widget build(BuildContext context) {
    final alertColor = alert.isExceeded ? AppColors.danger : AppColors.warning;

    return PremiumCard(
      color: alert.isExceeded ? const Color(0xFFFFF5F5) : const Color(0xFFFFFBF4),
      borderColor: alertColor.withOpacity(0.28),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alert.isExceeded ? Icons.error_rounded : Icons.warning_amber_rounded,
                color: alertColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: alertColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(
                '${(alert.ratio * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: alertColor,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(alert.message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ProgressLine(
            value: alert.ratio.clamp(0, 1),
            gradient: LinearGradient(colors: [alertColor, alertColor]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                MoneyFormatter.format(alert.used),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                MoneyFormatter.format(alert.limit),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmartLimitEmptyCard extends StatelessWidget {
  const _SmartLimitEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      color: const Color(0xFFF4FFFB),
      borderColor: AppColors.brandGreen.withOpacity(0.20),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.brandGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

String _analysisText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Aylık dağılım',
      'en': 'Monthly distribution',
      'ru': 'Месячное распределение',
    },
    'subtitle': {
      'tr': 'Gelirinin nereye dağıldığını sade bir görünümle takip et.',
      'en': 'Track where your income is distributed with a simple view.',
      'ru': 'Отслеживайте распределение дохода в простом виде.',
    },
    'planned': {
      'tr': 'Planlanan',
      'en': 'Planned',
      'ru': 'План',
    },
    'categories': {
      'tr': 'Kategoriler',
      'en': 'Categories',
      'ru': 'Категории',
    },
    'emptyCategory': {
      'tr': 'Kategori analizi için ödeme ekle.',
      'en': 'Add a payment for category analysis.',
      'ru': 'Добавьте платёж для анализа категорий.',
    },
    'emptyAnalysisTitle': {
      'tr': 'Analiz için veri yok',
      'en': 'No data for analysis yet',
      'ru': 'Пока нет данных для анализа',
    },
    'emptyAnalysisDescription': {
      'tr': 'Ödeme ve harcama ekledikten sonra kategoriler, oranlar ve aylık dağılım burada oluşacak.',
      'en': 'After you add payments and expenses, category ratios and monthly distribution will appear here.',
      'ru': 'После добавления платежей и расходов здесь появятся категории, доли и месячное распределение.',
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

    'smartLimitAlerts': {
      'tr': 'Akıllı limit uyarıları',
      'en': 'Smart limit alerts',
      'ru': 'Умные уведомления о лимитах',
    },
    'noSmartLimitAlerts': {
      'tr': 'Şu an kategori limitlerine yaklaşan veya limiti aşan bir harcama görünmüyor.',
      'en': 'No category is close to or over its limit right now.',
      'ru': 'Сейчас нет категорий, близких к лимиту или превысивших лимит.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _monthEndRemainingText(String code, String amount) {
  switch (code) {
    case 'en':
      return 'Estimated month-end remaining: $amount';
    case 'ru':
      return 'Прогноз остатка на конец месяца: $amount';
    case 'tr':
    default:
      return 'Ay sonu tahmini kalan: $amount';
  }
}

