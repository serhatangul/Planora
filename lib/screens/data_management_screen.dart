import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  Future<void> _confirmAndRun({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    final lang = PlanoraScope.of(context).appLanguageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_dataManagementText(lang, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_dataManagementText(lang, 'clear')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await action();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_completedText(lang, title))),
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
                        _dataManagementText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _dataManagementSubtitle(lang, _dataManagementMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.cleaning_services_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _dataManagementText(lang, 'intro'),
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
                SectionHeader(title: _dataManagementText(lang, 'selectedMonthSummary')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        label: _dataManagementText(lang, 'expense'),
                        value: '${controller.expenseCount}',
                        footer: MoneyFormatter.format(controller.expensesTotal),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryBox(
                        label: _dataManagementText(lang, 'extraIncome'),
                        value: '${controller.extraIncomeCount}',
                        footer: MoneyFormatter.format(controller.extraIncomeTotal),
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryBox(
                        label: _dataManagementText(lang, 'payment'),
                        value: '${controller.paymentsForSelectedMonth.length}',
                        footer: _paidCountText(lang, controller.paidPaymentCount),
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _dataManagementText(lang, 'clearSelectedMonthOnly')),
                const SizedBox(height: 12),
                _ActionCard(
                  title: _dataManagementText(lang, 'clearMonthExpensesTitle'),
                  subtitle: _dataManagementText(lang, 'clearMonthExpensesDescription'),
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.warning,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'clearExpensesDialogTitle'),
                    message: _dataManagementText(lang, 'clearMonthExpensesMessage'),
                    action: controller.clearSelectedMonthExpenses,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'clearMonthExtraIncomeTitle'),
                  subtitle: _dataManagementText(lang, 'clearMonthExtraIncomeDescription'),
                  icon: Icons.add_chart_rounded,
                  color: AppColors.brandGreen,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'clearExtraIncomeDialogTitle'),
                    message: _dataManagementText(lang, 'clearMonthExtraIncomeMessage'),
                    action: controller.clearSelectedMonthExtraIncomes,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'resetMonthPaymentStatusTitle'),
                  subtitle: _dataManagementText(lang, 'resetMonthPaymentStatusDescription'),
                  icon: Icons.check_circle_rounded,
                  color: AppColors.brandBlue,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'resetPaymentStatusDialogTitle'),
                    message: _dataManagementText(lang, 'resetMonthPaymentStatusMessage'),
                    action: controller.clearSelectedMonthPaymentStatuses,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'deleteMonthOneTimePaymentsTitle'),
                  subtitle: _dataManagementText(lang, 'deleteMonthOneTimePaymentsDescription'),
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.danger,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'deleteOneTimePaymentsDialogTitle'),
                    message: _dataManagementText(lang, 'deleteMonthOneTimePaymentsMessage'),
                    action: controller.clearSelectedMonthOneTimePayments,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'clearSelectedMonthTitle'),
                  subtitle: _dataManagementText(lang, 'clearSelectedMonthDescription'),
                  icon: Icons.delete_sweep_rounded,
                  color: AppColors.danger,
                  danger: true,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'clearSelectedMonthDialogTitle'),
                    message: _dataManagementText(lang, 'clearSelectedMonthMessage'),
                    action: controller.clearSelectedMonthData,
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _dataManagementText(lang, 'generalCleanup')),
                const SizedBox(height: 12),
                _ActionCard(
                  title: _dataManagementText(lang, 'clearAllExpensesTitle'),
                  subtitle: _dataManagementText(lang, 'clearAllExpensesDescription'),
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.warning,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'clearAllExpensesTitle'),
                    message: _dataManagementText(lang, 'clearAllExpensesMessage'),
                    action: controller.clearAllExpenses,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'clearAllExtraIncomeTitle'),
                  subtitle: _dataManagementText(lang, 'clearAllExtraIncomeDescription'),
                  icon: Icons.add_chart_rounded,
                  color: AppColors.brandGreen,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'clearAllExtraIncomeTitle'),
                    message: _dataManagementText(lang, 'clearAllExtraIncomeMessage'),
                    action: controller.clearAllExtraIncomes,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'resetAllPaymentStatusTitle'),
                  subtitle: _dataManagementText(lang, 'resetAllPaymentStatusDescription'),
                  icon: Icons.restart_alt_rounded,
                  color: AppColors.brandBlue,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'resetAllPaymentStatusTitle'),
                    message: _dataManagementText(lang, 'resetAllPaymentStatusMessage'),
                    action: controller.clearAllPaymentStatuses,
                  ),
                ),
                _ActionCard(
                  title: _dataManagementText(lang, 'deleteAllOneTimePaymentsTitle'),
                  subtitle: _dataManagementText(lang, 'deleteAllOneTimePaymentsDescription'),
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  danger: true,
                  onTap: () => _confirmAndRun(
                    context: context,
                    title: _dataManagementText(lang, 'deleteOneTimePaymentsDialogTitle'),
                    message: _dataManagementText(lang, 'deleteAllOneTimePaymentsMessage'),
                    action: controller.clearAllOneTimePayments,
                  ),
                ),
                const SizedBox(height: 16),
                PremiumCard(
                  color: const Color(0xFFFFFBF4),
                  borderColor: AppColors.warning.withOpacity(0.24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dataManagementText(lang, 'backupTip'),
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


String _dataManagementText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'cancel': {'tr': 'Vazgeç', 'en': 'Cancel', 'ru': 'Отмена'},
    'clear': {'tr': 'Temizle', 'en': 'Clear', 'ru': 'Очистить'},
    'title': {'tr': 'Veri yönetimi', 'en': 'Data management', 'ru': 'Управление данными'},
    'intro': {
      'tr': 'Tüm uygulamayı sıfırlamadan sadece ihtiyacın olan veri tiplerini temizleyebilirsin.',
      'en': 'You can clear only the data types you need without resetting the whole app.',
      'ru': 'Можно очистить только нужные типы данных без полного сброса приложения.',
    },
    'selectedMonthSummary': {'tr': 'Seçili ay özeti', 'en': 'Selected month summary', 'ru': 'Сводка месяца'},
    'expense': {'tr': 'Harcama', 'en': 'Expense', 'ru': 'Расходы'},
    'extraIncome': {'tr': 'Ek gelir', 'en': 'Extra income', 'ru': 'Доп. доход'},
    'payment': {'tr': 'Ödeme', 'en': 'Payment', 'ru': 'Платёж'},
    'clearSelectedMonthOnly': {'tr': 'Sadece seçili ayı temizle', 'en': 'Clear selected month only', 'ru': 'Очистить выбранный месяц'},
    'generalCleanup': {'tr': 'Genel temizlik', 'en': 'General cleanup', 'ru': 'Общая очистка'},
    'backupTip': {
      'tr': 'Temizleme işlemlerinden önce Profil > Verileri yedekle bölümünden yedek almak güvenlidir.',
      'en': 'Before clearing data, it is safer to create a backup from Profile > Backup data.',
      'ru': 'Перед очисткой данных безопаснее создать резервную копию в Профиль > Резервное копирование.',
    },
    'clearMonthExpensesTitle': {'tr': 'Bu ayın harcamalarını temizle', 'en': 'Clear this month’s expenses', 'ru': 'Очистить расходы месяца'},
    'clearMonthExpensesDescription': {'tr': 'Sadece seçili aya ait harcama kayıtları silinir.', 'en': 'Only expense records for the selected month will be deleted.', 'ru': 'Будут удалены только расходы выбранного месяца.'},
    'clearExpensesDialogTitle': {'tr': 'Harcamaları temizle', 'en': 'Clear expenses', 'ru': 'Очистить расходы'},
    'clearMonthExpensesMessage': {'tr': 'Seçili ayın tüm harcama kayıtları silinecek. Devam etmek istiyor musun?', 'en': 'All expense records for the selected month will be deleted. Do you want to continue?', 'ru': 'Все расходы выбранного месяца будут удалены. Продолжить?'},
    'clearMonthExtraIncomeTitle': {'tr': 'Bu ayın ek gelirlerini temizle', 'en': 'Clear this month’s extra income', 'ru': 'Очистить доп. доход месяца'},
    'clearMonthExtraIncomeDescription': {'tr': 'Sadece seçili aya ait ek gelir kayıtları silinir.', 'en': 'Only extra income records for the selected month will be deleted.', 'ru': 'Будут удалены только доп. доходы выбранного месяца.'},
    'clearExtraIncomeDialogTitle': {'tr': 'Ek gelirleri temizle', 'en': 'Clear extra income', 'ru': 'Очистить доп. доход'},
    'clearMonthExtraIncomeMessage': {'tr': 'Seçili ayın tüm ek gelir kayıtları silinecek. Devam etmek istiyor musun?', 'en': 'All extra income records for the selected month will be deleted. Do you want to continue?', 'ru': 'Все доп. доходы выбранного месяца будут удалены. Продолжить?'},
    'resetMonthPaymentStatusTitle': {'tr': 'Bu ayın ödeme durumlarını sıfırla', 'en': 'Reset this month’s payment statuses', 'ru': 'Сбросить статусы платежей месяца'},
    'resetMonthPaymentStatusDescription': {'tr': 'Ödendi/bekliyor işaretleri seçili ay için sıfırlanır.', 'en': 'Paid/waiting marks are reset for the selected month.', 'ru': 'Метки оплачено/ожидает будут сброшены за выбранный месяц.'},
    'resetPaymentStatusDialogTitle': {'tr': 'Ödeme durumlarını sıfırla', 'en': 'Reset payment statuses', 'ru': 'Сбросить статусы платежей'},
    'resetMonthPaymentStatusMessage': {'tr': 'Seçili ayın ödendi/bekliyor durumları sıfırlanacak. Aylık ödemeler silinmez.', 'en': 'Paid/waiting statuses for the selected month will be reset. Monthly payments will not be deleted.', 'ru': 'Статусы оплачено/ожидает будут сброшены. Ежемесячные платежи не удаляются.'},
    'deleteMonthOneTimePaymentsTitle': {'tr': 'Bu ayın tek seferlik ödemelerini sil', 'en': 'Delete this month’s one-time payments', 'ru': 'Удалить разовые платежи месяца'},
    'deleteMonthOneTimePaymentsDescription': {'tr': 'Aylık ödemeler korunur, sadece bu aya ait tek seferlik ödemeler silinir.', 'en': 'Monthly payments are kept; only one-time payments for this month are deleted.', 'ru': 'Ежемесячные платежи сохраняются; удаляются только разовые платежи этого месяца.'},
    'deleteOneTimePaymentsDialogTitle': {'tr': 'Tek seferlik ödemeleri sil', 'en': 'Delete one-time payments', 'ru': 'Удалить разовые платежи'},
    'deleteMonthOneTimePaymentsMessage': {'tr': 'Seçili aya ait tek seferlik ödemeler silinecek. Aylık ödemeler korunur.', 'en': 'One-time payments for the selected month will be deleted. Monthly payments are kept.', 'ru': 'Разовые платежи выбранного месяца будут удалены. Ежемесячные платежи сохраняются.'},
    'clearSelectedMonthTitle': {'tr': 'Seçili ayı tamamen temizle', 'en': 'Clear selected month completely', 'ru': 'Полностью очистить выбранный месяц'},
    'clearSelectedMonthDescription': {'tr': 'Bu ayın harcama, ek gelir, ödeme durumu ve tek seferlik ödemeleri temizlenir.', 'en': 'Expenses, extra income, payment statuses, and one-time payments for this month are cleared.', 'ru': 'Будут очищены расходы, доп. доходы, статусы платежей и разовые платежи за этот месяц.'},
    'clearSelectedMonthDialogTitle': {'tr': 'Seçili ayı temizle', 'en': 'Clear selected month', 'ru': 'Очистить выбранный месяц'},
    'clearSelectedMonthMessage': {'tr': 'Seçili aya ait harcamalar, ek gelirler, ödeme durumları ve tek seferlik ödemeler temizlenecek. Aylık ödemeler korunur.', 'en': 'Expenses, extra income, payment statuses, and one-time payments for the selected month will be cleared. Monthly payments are kept.', 'ru': 'Данные выбранного месяца будут очищены. Ежемесячные платежи сохраняются.'},
    'clearAllExpensesTitle': {'tr': 'Tüm harcamaları temizle', 'en': 'Clear all expenses', 'ru': 'Очистить все расходы'},
    'clearAllExpensesDescription': {'tr': 'Tüm aylardaki değişken harcamalar silinir.', 'en': 'Variable expenses across all months are deleted.', 'ru': 'Расходы за все месяцы будут удалены.'},
    'clearAllExpensesMessage': {'tr': 'Tüm aylara ait harcama kayıtları silinecek. Devam etmek istiyor musun?', 'en': 'Expense records for all months will be deleted. Do you want to continue?', 'ru': 'Расходы за все месяцы будут удалены. Продолжить?'},
    'clearAllExtraIncomeTitle': {'tr': 'Tüm ek gelirleri temizle', 'en': 'Clear all extra income', 'ru': 'Очистить все доп. доходы'},
    'clearAllExtraIncomeDescription': {'tr': 'Tüm aylardaki ek gelir kayıtları silinir.', 'en': 'Extra income records across all months are deleted.', 'ru': 'Доп. доходы за все месяцы будут удалены.'},
    'clearAllExtraIncomeMessage': {'tr': 'Tüm aylara ait ek gelir kayıtları silinecek. Devam etmek istiyor musun?', 'en': 'Extra income records for all months will be deleted. Do you want to continue?', 'ru': 'Доп. доходы за все месяцы будут удалены. Продолжить?'},
    'resetAllPaymentStatusTitle': {'tr': 'Tüm ödeme durumlarını sıfırla', 'en': 'Reset all payment statuses', 'ru': 'Сбросить все статусы платежей'},
    'resetAllPaymentStatusDescription': {'tr': 'Tüm aylardaki ödendi/bekliyor işaretleri sıfırlanır.', 'en': 'Paid/waiting marks across all months are reset.', 'ru': 'Метки оплачено/ожидает за все месяцы будут сброшены.'},
    'resetAllPaymentStatusMessage': {'tr': 'Tüm aylardaki ödeme durumları sıfırlanacak. Ödeme kayıtları silinmez.', 'en': 'Payment statuses across all months will be reset. Payment records will not be deleted.', 'ru': 'Статусы платежей за все месяцы будут сброшены. Платежи не удаляются.'},
    'deleteAllOneTimePaymentsTitle': {'tr': 'Tüm tek seferlik ödemeleri sil', 'en': 'Delete all one-time payments', 'ru': 'Удалить все разовые платежи'},
    'deleteAllOneTimePaymentsDescription': {'tr': 'Aylık ödemeler korunur, tek seferlik ödemeler silinir.', 'en': 'Monthly payments are kept; one-time payments are deleted.', 'ru': 'Ежемесячные платежи сохраняются; разовые платежи удаляются.'},
    'deleteAllOneTimePaymentsMessage': {'tr': 'Tüm tek seferlik ödemeler silinecek. Aylık ödemeler korunur.', 'en': 'All one-time payments will be deleted. Monthly payments are kept.', 'ru': 'Все разовые платежи будут удалены. Ежемесячные платежи сохраняются.'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _dataManagementMonthYearLabel(String code, DateTime month) {
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

String _dataManagementSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return '$month and general data cleanup options';
    case 'ru':
      return 'Очистка данных за $month и общие настройки';
    case 'tr':
    default:
      return '$month ve genel veri temizleme seçenekleri';
  }
}

String _paidCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count paid';
    case 'ru':
      return '$count оплачено';
    case 'tr':
    default:
      return '$count ödendi';
  }
}

String _completedText(String code, String title) {
  switch (code) {
    case 'en':
      return '$title completed.';
    case 'ru':
      return '$title выполнено.';
    case 'tr':
    default:
      return '$title tamamlandı.';
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.footer,
    required this.color,
  });

  final String label;
  final String value;
  final String footer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(footer, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        borderColor: danger ? AppColors.danger.withOpacity(0.35) : AppColors.stroke,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
