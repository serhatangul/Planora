import 'package:flutter/material.dart';

import '../models/payment_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/planora_empty_state.dart';
import 'add_payment_screen.dart';
import 'edit_payment_screen.dart';

enum PaymentListFilter {
  all,
  waiting,
  paid,
  late,
  monthly,
  oneTime,
}

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchController = TextEditingController();
  PaymentListFilter _filter = PaymentListFilter.all;

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


  Future<void> _openOneTimePaymentAdd(BuildContext context) async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    final result = await showDialog<_OneTimePaymentInput>(
      context: context,
      builder: (_) => _OneTimePaymentDialog(
        lang: lang,
        currencySymbol: controller.currencySymbol,
      ),
    );

    if (result == null || result.title.trim().isEmpty || result.amount <= 0) {
      return;
    }

    final today = DateTime.now().day;

    await controller.addExpense(
      title: result.title.trim(),
      category: 'Diğer',
      amount: result.amount,
      day: today,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_paymentsShortText(lang, 'oneTimeAdded'))),
    );
  }



  List<PaymentItem> _filteredPayments(PlanoraController controller) {
    final query = _searchController.text.trim().toLowerCase();

    var payments = controller.paymentsForSelectedMonth;

    switch (_filter) {
      case PaymentListFilter.all:
        break;
      case PaymentListFilter.waiting:
        payments = payments
            .where((payment) => !controller.isPaymentPaid(payment))
            .where((payment) => !controller.isPaymentLate(payment))
            .toList();
        break;
      case PaymentListFilter.paid:
        payments = payments.where(controller.isPaymentPaid).toList();
        break;
      case PaymentListFilter.late:
        payments = payments.where(controller.isPaymentLate).toList();
        break;
      case PaymentListFilter.monthly:
        payments = payments.where((payment) => payment.isMonthly).toList();
        break;
      case PaymentListFilter.oneTime:
        payments = payments.where((payment) => !payment.isMonthly).toList();
        break;
    }

    if (query.isNotEmpty) {
      payments = payments.where((payment) {
        return controller.paymentTitleSearchText(payment.title).contains(query) ||
            controller.categorySearchText(payment.category).contains(query) ||
            payment.amount.round().toString().contains(query);
      }).toList();
    }

    payments.sort((a, b) {
      final aLate = controller.isPaymentLate(a);
      final bLate = controller.isPaymentLate(b);

      if (aLate != bLate) return aLate ? -1 : 1;

      final aPaid = controller.isPaymentPaid(a);
      final bPaid = controller.isPaymentPaid(b);

      if (aPaid != bPaid) return aPaid ? 1 : -1;

      return a.dueDay.compareTo(b.dueDay);
    });

    return payments;
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
            final payments = _filteredPayments(controller);
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
                        _paymentsTitleText(lang),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openPaymentAdd(context),
                      icon: const Icon(Icons.add_circle_rounded),
                      color: AppColors.brandGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _paymentsMonthSubtitleText(lang, _paymentsMonthYearLabel(lang, controller.selectedMonth)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _paymentsTotalLabelText(lang),
                              style: TextStyle(
                                color: Color(0xFFC8D3FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MoneyFormatter.format(controller.plannedPayments),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _paymentsCountText(lang, controller.paymentsForSelectedMonth.length),
                        style: const TextStyle(
                          color: Color(0xFF9FFFE0),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentMiniStat(
                        label: _paymentsShortText(lang, 'waiting'),
                        value: controller.paymentsForSelectedMonth
                            .where((payment) => !controller.isPaymentPaid(payment) && !controller.isPaymentLate(payment))
                            .length
                            .toString(),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PaymentMiniStat(
                        label: _paymentsShortText(lang, 'paid'),
                        value: controller.paymentsForSelectedMonth
                            .where(controller.isPaymentPaid)
                            .length
                            .toString(),
                        color: AppColors.brandGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PaymentMiniStat(
                        label: _paymentsShortText(lang, 'late'),
                        value: controller.paymentsForSelectedMonth
                            .where(controller.isPaymentLate)
                            .length
                            .toString(),
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentQuickActionCard(
                        title: _paymentsShortText(lang, 'monthlyPaymentTitle'),
                        subtitle: _paymentsShortText(lang, 'monthlyPaymentSubtitle'),
                        icon: Icons.repeat_rounded,
                        color: AppColors.brandBlue,
                        onTap: () => _openPaymentAdd(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentQuickActionCard(
                        title: _paymentsShortText(lang, 'oneTimePaymentTitle'),
                        subtitle: _paymentsShortText(lang, 'oneTimePaymentSubtitle'),
                        icon: Icons.add_card_rounded,
                        color: AppColors.brandGreen,
                        onTap: () => _openOneTimePaymentAdd(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _paymentsShortText(lang, 'searchHint'),
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
                      _FilterChip(
                        label: _paymentsShortText(lang, 'all'),
                        active: _filter == PaymentListFilter.all,
                        onTap: () => setState(() => _filter = PaymentListFilter.all),
                      ),
                      _FilterChip(
                        label: _paymentsShortText(lang, 'waiting'),
                        active: _filter == PaymentListFilter.waiting,
                        onTap: () => setState(() => _filter = PaymentListFilter.waiting),
                      ),
                      _FilterChip(
                        label: _paymentsShortText(lang, 'paid'),
                        active: _filter == PaymentListFilter.paid,
                        onTap: () => setState(() => _filter = PaymentListFilter.paid),
                      ),
                      _FilterChip(
                        label: _paymentsShortText(lang, 'late'),
                        active: _filter == PaymentListFilter.late,
                        onTap: () => setState(() => _filter = PaymentListFilter.late),
                      ),
                      _FilterChip(
                        label: _paymentsShortText(lang, 'monthly'),
                        active: _filter == PaymentListFilter.monthly,
                        onTap: () => setState(() => _filter = PaymentListFilter.monthly),
                      ),
                      _FilterChip(
                        label: _paymentsShortText(lang, 'oneTime'),
                        active: _filter == PaymentListFilter.oneTime,
                        onTap: () => setState(() => _filter = PaymentListFilter.oneTime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SectionHeader(
                  title: _paymentsShortText(lang, 'results'),
                  actionLabel: _paymentsCountText(lang, payments.length),
                ),
                const SizedBox(height: 12),
                if (payments.isEmpty)
                  PlanoraEmptyState(
                    icon: controller.paymentsForSelectedMonth.isEmpty
                        ? Icons.receipt_long_rounded
                        : Icons.search_off_rounded,
                    title: controller.paymentsForSelectedMonth.isEmpty
                        ? _paymentsEmptyText(lang, 'noPaymentsTitle')
                        : _paymentsEmptyText(lang, 'noFilterResultsTitle'),
                    description: controller.paymentsForSelectedMonth.isEmpty
                        ? _paymentsEmptyText(lang, 'noPaymentsDescription')
                        : _paymentsEmptyText(lang, 'noFilterResultsDescription'),
                    actionLabel: controller.paymentsForSelectedMonth.isEmpty ? _paymentsEmptyText(lang, 'addPayment') : null,
                    onActionTap: controller.paymentsForSelectedMonth.isEmpty ? () => _openPaymentAdd(context) : null,
                    color: AppColors.brandBlue,
                  )
                else
                  ...payments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaymentCard(
                        lang: lang,
                        payment: payment,
                        isPaid: controller.isPaymentPaid(payment),
                        isLate: controller.isPaymentLate(payment),
                        onTap: () => _openPaymentEdit(context, payment.id),
                        onStatusTap: () => controller.togglePaymentPaid(payment.id),
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




String _paymentsMonthYearLabel(String code, DateTime month) {
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

String _paymentsTitleText(String code) {
  switch (code) {
    case 'en':
      return 'All payments';
    case 'ru':
      return 'Все платежи';
    case 'tr':
    default:
      return 'Tüm ödemeler';
  }
}


String _paymentsMonthSubtitleText(String code, String month) {
  switch (code) {
    case 'en':
      return '$month payment list';
    case 'ru':
      return 'Список платежей за $month';
    case 'tr':
    default:
      return '$month ödeme listesi';
  }
}

String _paymentsTotalLabelText(String code) {
  switch (code) {
    case 'en':
      return 'Monthly payment total';
    case 'ru':
      return 'Сумма платежей за месяц';
    case 'tr':
    default:
      return 'Aylık ödeme toplamı';
  }
}

String _paymentsCountText(String code, int count) {
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


String _paymentsShortText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'waiting': {
      'tr': 'Bekliyor',
      'en': 'Waiting',
      'ru': 'Ожидает',
    },
    'paid': {
      'tr': 'Ödendi',
      'en': 'Paid',
      'ru': 'Оплачено',
    },
    'late': {
      'tr': 'Gecikti',
      'en': 'Late',
      'ru': 'Просрочено',
    },
    'searchHint': {
      'tr': 'Ödeme veya kategori ara',
      'en': 'Search payment or category',
      'ru': 'Поиск платежа или категории',
    },
    'all': {
      'tr': 'Tümü',
      'en': 'All',
      'ru': 'Все',
    },
    'monthly': {
      'tr': 'Aylık',
      'en': 'Monthly',
      'ru': 'Ежемесячно',
    },
    'oneTime': {
      'tr': 'Tek sefer',
      'en': 'One-time',
      'ru': 'Разовый',
    },
    'monthlyPaymentTitle': {
      'tr': 'Aylık ödeme',
      'en': 'Monthly payment',
      'ru': 'Ежемесячный платёж',
    },
    'monthlyPaymentSubtitle': {
      'tr': 'Kira, kredi, fatura',
      'en': 'Rent, loan, bill',
      'ru': 'Аренда, кредит, счёт',
    },
    'oneTimePaymentTitle': {
      'tr': 'Tek seferlik harcama',
      'en': 'One-time expense',
      'ru': 'Разовый расход',
    },
    'oneTimePaymentSubtitle': {
      'tr': 'Diğer kategorisine eklenir',
      'en': 'Saved under Other',
      'ru': 'В категорию Другое',
    },
    'oneTimeDialogTitle': {
      'tr': 'Tek seferlik harcama',
      'en': 'One-time expense',
      'ru': 'Разовый расход',
    },
    'paymentName': {
      'tr': 'Ödeme adı',
      'en': 'Payment name',
      'ru': 'Название платежа',
    },
    'amount': {
      'tr': 'Tutar',
      'en': 'Amount',
      'ru': 'Сумма',
    },
    'cancel': {
      'tr': 'Vazgeç',
      'en': 'Cancel',
      'ru': 'Отмена',
    },
    'add': {
      'tr': 'Ekle',
      'en': 'Add',
      'ru': 'Добавить',
    },
    'oneTimeAdded': {
      'tr': 'Tek seferlik harcama bugüne Diğer kategorisiyle eklendi.',
      'en': 'One-time expense added for today under Other.',
      'ru': 'Разовый расход добавлен на сегодня в категорию Другое.',
    },
    'otherCategory': {
      'tr': 'Diğer',
      'en': 'Other',
      'ru': 'Другое',
    },
    'results': {
      'tr': 'Sonuçlar',
      'en': 'Results',
      'ru': 'Результаты',
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
    'monthlyType': {
      'tr': 'Aylık',
      'en': 'Monthly',
      'ru': 'Ежемесячно',
    },
    'oneTimeType': {
      'tr': 'Tek sefer',
      'en': 'One-time',
      'ru': 'Разовый',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _paymentsEmptyText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'noPaymentsTitle': {
      'tr': 'Henüz ödeme yok',
      'en': 'No payments yet',
      'ru': 'Платежей пока нет',
    },
    'noFilterResultsTitle': {
      'tr': 'Filtreye uygun ödeme yok',
      'en': 'No payments match this filter',
      'ru': 'Нет платежей по этому фильтру',
    },
    'noPaymentsDescription': {
      'tr': 'İlk sabit ödemenizi ekleyerek aylık ödeme planınızı oluşturmaya başlayın.',
      'en': 'Add your first fixed payment to start building your monthly payment plan.',
      'ru': 'Добавьте первый регулярный платёж, чтобы начать формировать месячный план.',
    },
    'noFilterResultsDescription': {
      'tr': 'Arama kelimesini veya üstteki filtreleri değiştirerek tekrar deneyebilirsin.',
      'en': 'Change the search term or filters above and try again.',
      'ru': 'Измените поисковый запрос или фильтры выше и попробуйте снова.',
    },
    'addPayment': {
      'tr': 'İlk Ödemeyi Ekle',
      'en': 'Add First Payment',
      'ru': 'Добавить первый платёж',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _paymentCardStatusText(String code, String status, bool isMonthly) {
  final typeText = _paymentsShortText(code, isMonthly ? 'monthlyType' : 'oneTimeType');

  switch (code) {
    case 'en':
      return 'Paid · $typeText';
    case 'ru':
      return 'Оплачено · $typeText';
    case 'tr':
    default:
      return 'Ödendi · $typeText';
  }
}

String _paymentCardLateText(String code, String category) {
  switch (code) {
    case 'en':
      return 'Late payment · $category';
    case 'ru':
      return 'Просроченный платёж · $category';
    case 'tr':
    default:
      return 'Gecikmiş ödeme · $category';
  }
}

String _paymentCardDayText(String code, int day, String category, bool isMonthly) {
  final typeText = _paymentsShortText(code, isMonthly ? 'monthlyType' : 'oneTimeType');

  switch (code) {
    case 'en':
      return 'Day $day · $category · $typeText';
    case 'ru':
      return '$day-й день · $category · $typeText';
    case 'tr':
    default:
      return '$day. gün · $category · $typeText';
  }
}


class _PaymentQuickActionCard extends StatelessWidget {
  const _PaymentQuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: color.withOpacity(0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _OneTimePaymentInput {
  const _OneTimePaymentInput({
    required this.title,
    required this.amount,
  });

  final String title;
  final double amount;
}

class _OneTimePaymentDialog extends StatefulWidget {
  const _OneTimePaymentDialog({
    required this.lang,
    required this.currencySymbol,
  });

  final String lang;
  final String currencySymbol;

  @override
  State<_OneTimePaymentDialog> createState() => _OneTimePaymentDialogState();
}

class _OneTimePaymentDialogState extends State<_OneTimePaymentDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = MoneyFormatter.parseAmount(_amountController.text);

    if (title.isEmpty || amount <= 0) return;

    Navigator.of(context).pop(
      _OneTimePaymentInput(title: title, amount: amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_paymentsShortText(widget.lang, 'oneTimeDialogTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _paymentsShortText(widget.lang, 'paymentName'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: _paymentsShortText(widget.lang, 'amount'),
              prefixText: '${widget.currencySymbol} ',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_paymentsShortText(widget.lang, 'cancel')),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(_paymentsShortText(widget.lang, 'add')),
        ),
      ],
    );
  }
}


class _PaymentMiniStat extends StatelessWidget {
  const _PaymentMiniStat({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      color: Colors.white,
      borderColor: color.withOpacity(0.20),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.lang,
    required this.payment,
    required this.isPaid,
    required this.isLate,
    required this.onTap,
    required this.onStatusTap,
  });

  final String lang;
  final PaymentItem payment;
  final bool isPaid;
  final bool isLate;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
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
                            ? _paymentCardStatusText(lang, 'paid', payment.isMonthly)
                            : isLate
                                ? _paymentCardLateText(lang, PlanoraScope.of(context).categoryLabel(payment.category))
                                : _paymentCardDayText(lang, payment.dueDay, PlanoraScope.of(context).categoryLabel(payment.category), payment.isMonthly),
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
            lang: lang,
            isPaid: isPaid,
            onTap: onStatusTap,
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusButton extends StatelessWidget {
  const _PaymentStatusButton({
    required this.lang,
    required this.isPaid,
    required this.onTap,
  });

  final String lang;
  final bool isPaid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPaid ? const Color(0xFFE8FFF6) : const Color(0xFFFFF6E5);
    final textColor = isPaid ? const Color(0xFF0A7A59) : AppColors.warning;
    final icon = isPaid ? Icons.undo_rounded : Icons.check_circle_rounded;
    final label = isPaid ? _paymentsShortText(lang, 'markWaiting') : _paymentsShortText(lang, 'markPaid');

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
