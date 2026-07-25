import 'package:flutter/material.dart';

import '../models/income_item.dart';
import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_planora.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class ExtraIncomeScreen extends StatefulWidget {
  const ExtraIncomeScreen({super.key});

  @override
  State<ExtraIncomeScreen> createState() => _ExtraIncomeScreenState();
}

class _ExtraIncomeScreenState extends State<ExtraIncomeScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController(text: DateTime.now().day.toString());

  bool _showForm = false;
  String? _editingIncomeId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  String _capitalize(String value) {
    if (value.trim().isEmpty) return value;

    final index = value.indexOf(RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]'));
    if (index == -1) return value;

    return value.substring(0, index) +
        value[index].toUpperCase() +
        value.substring(index + 1);
  }

  void _startAdd() {
    setState(() {
      _editingIncomeId = null;
      _titleController.clear();
      _amountController.clear();
      _dayController.text = DateTime.now().day.toString();
      _showForm = true;
    });
  }

  void _startEdit(IncomeItem income) {
    setState(() {
      _editingIncomeId = income.id;
      _titleController.text = income.title;
      _amountController.text = income.amount.round().toString();
      _dayController.text = income.day.toString();
      _showForm = true;
    });
  }

  void _cancelForm() {
    FocusScope.of(context).unfocus();

    setState(() {
      _editingIncomeId = null;
      _titleController.clear();
      _amountController.clear();
      _showForm = false;
    });
  }

  Future<void> _saveIncome() async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;
    final amount = MoneyFormatter.parseAmount(_amountController.text);
    final day = int.tryParse(_dayController.text.trim()) ?? DateTime.now().day;
    final title = _capitalize(_titleController.text.trim());

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_extraIncomeText(lang, 'invalidAmount'))),
      );
      return;
    }

    if (_editingIncomeId == null) {
      await controller.addExtraIncome(
        title: title,
        amount: amount,
        day: day,
      );
    } else {
      await controller.updateExtraIncome(
        id: _editingIncomeId!,
        title: title,
        amount: amount,
        day: day,
      );
    }

    if (!mounted) return;
    _cancelForm();
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
                        _extraIncomeText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _extraIncomeMonthSubtitle(lang, _extraIncomeMonthYearLabel(lang, controller.selectedMonth)),
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
                        child: const Icon(Icons.add_chart_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _extraIncomeText(lang, 'thisMonthExtraIncome'),
                              style: TextStyle(
                                color: Color(0xFFC8D3FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MoneyFormatter.format(controller.extraIncomeTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _recordCountText(lang, controller.extraIncomeCount),
                        style: const TextStyle(
                          color: Color(0xFF9FFFE0),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_showForm)
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: _editingIncomeId == null ? _extraIncomeText(lang, 'newExtraIncome') : _extraIncomeText(lang, 'editExtraIncome'),
                          actionLabel: _extraIncomeText(lang, 'close'),
                          onActionTap: _cancelForm,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _extraIncomeText(lang, 'incomeName'),
                          controller: _titleController,
                          icon: Icons.edit_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _extraIncomeText(lang, 'amount'),
                          controller: _amountController,
                          icon: Icons.currency_lira_rounded,
                          prefix: controller.currencySymbol,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        _InputField(
                          label: _extraIncomeText(lang, 'day'),
                          controller: _dayController,
                          icon: Icons.calendar_today_rounded,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Material(
                            color: AppColors.darkNavy,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _saveIncome,
                              child: Center(
                                child: Text(
                                  _editingIncomeId == null ? _extraIncomeText(lang, 'saveExtraIncome') : _extraIncomeText(lang, 'save'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 54,
                    child: Material(
                      color: AppColors.darkNavy,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _startAdd,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                _extraIncomeText(lang, 'addExtraIncome'),
                                style: TextStyle(
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
                const SizedBox(height: 24),
                SectionHeader(
                  title: _extraIncomeText(lang, 'incomeList'),
                  actionLabel: _recordCountText(lang, controller.extraIncomesForSelectedMonth.length),
                ),
                const SizedBox(height: 12),
                if (controller.extraIncomesForSelectedMonth.isEmpty)
                  PremiumCard(
                    child: Column(
                      children: [
                        const Icon(Icons.add_chart_rounded, color: AppColors.textSecondary, size: 38),
                        const SizedBox(height: 10),
                        Text(
                          _extraIncomeText(lang, 'emptyRecordMessage'),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...controller.extraIncomesForSelectedMonth.map(
                    (income) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(income.id),
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
                        onDismissed: (_) => controller.removeExtraIncome(income.id),
                        child: _IncomeCard(
                          income: income,
                          onTap: () => _startEdit(income),
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


String _extraIncomeText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidAmount': {
      'tr': 'Lütfen geçerli bir ek gelir tutarı gir.',
      'en': 'Please enter a valid extra income amount.',
      'ru': 'Введите корректную сумму дополнительного дохода.',
    },
    'title': {
      'tr': 'Ek gelirler',
      'en': 'Extra income',
      'ru': 'Дополнительные доходы',
    },
    'thisMonthExtraIncome': {
      'tr': 'Bu ay ek gelir',
      'en': 'Extra income this month',
      'ru': 'Доп. доход за месяц',
    },
    'newExtraIncome': {
      'tr': 'Yeni ek gelir',
      'en': 'New extra income',
      'ru': 'Новый доп. доход',
    },
    'editExtraIncome': {
      'tr': 'Ek geliri düzenle',
      'en': 'Edit extra income',
      'ru': 'Редактировать доп. доход',
    },
    'close': {
      'tr': 'Kapat',
      'en': 'Close',
      'ru': 'Закрыть',
    },
    'incomeName': {
      'tr': 'Gelir adı',
      'en': 'Income name',
      'ru': 'Название дохода',
    },
    'amount': {
      'tr': 'Tutar',
      'en': 'Amount',
      'ru': 'Сумма',
    },
    'day': {
      'tr': 'Gün',
      'en': 'Day',
      'ru': 'День',
    },
    'addIncomeAction': {
      'tr': 'Geliri Ekle',
      'en': 'Add Income',
      'ru': 'Добавить доход',
    },
    'saveExtraIncome': {
      'tr': 'Ek Geliri Kaydet',
      'en': 'Save Extra Income',
      'ru': 'Сохранить доп. доход',
    },
    'save': {
      'tr': 'Kaydet',
      'en': 'Save',
      'ru': 'Сохранить',
    },
    'addExtraIncome': {
      'tr': 'Ek Gelir Ekle',
      'en': 'Add Extra Income',
      'ru': 'Добавить доп. доход',
    },
    'searchHint': {
      'tr': 'Gelir, tutar veya gün ara',
      'en': 'Search income, amount, or day',
      'ru': 'Поиск по доходу, сумме или дню',
    },
    'newToOld': {
      'tr': 'Yeni → Eski',
      'en': 'Newest → Oldest',
      'ru': 'Новые → Старые',
    },
    'oldToNew': {
      'tr': 'Eski → Yeni',
      'en': 'Oldest → Newest',
      'ru': 'Старые → Новые',
    },
    'amountHigh': {
      'tr': 'Tutar yüksek',
      'en': 'Highest amount',
      'ru': 'Сумма выше',
    },
    'amountLow': {
      'tr': 'Tutar düşük',
      'en': 'Lowest amount',
      'ru': 'Сумма ниже',
    },
    'incomeList': {
      'tr': 'Ek gelir listesi',
      'en': 'Extra income list',
      'ru': 'Список доп. доходов',
    },
    'emptyTitle': {
      'tr': 'Bu ay henüz ek gelir yok',
      'en': 'No extra income yet this month',
      'ru': 'В этом месяце доп. доходов пока нет',
    },
    'filterEmptyTitle': {
      'tr': 'Filtreye uygun ek gelir yok',
      'en': 'No extra income matches this filter',
      'ru': 'Нет доп. доходов по этому фильтру',
    },
    'emptyDescription': {
      'tr': 'Maaş dışında gelen ek kazançlarını ekleyerek aylık bütçeni daha net görebilirsin.',
      'en': 'Add income outside your salary to see your monthly budget more clearly.',
      'ru': 'Добавьте доходы помимо зарплаты, чтобы точнее видеть месячный бюджет.',
    },
    'emptyRecordMessage': {
      'tr': 'Bu ay için ek gelir kaydı yok.',
      'en': 'No extra income record for this month.',
      'ru': 'За этот месяц записей доп. дохода нет.',
    },
    'filterEmptyDescription': {
      'tr': 'Arama kelimesini veya sıralamayı değiştirerek tekrar deneyebilirsin.',
      'en': 'Change the search term or sorting and try again.',
      'ru': 'Измените поиск или сортировку и попробуйте снова.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


String _extraIncomeMonthYearLabel(String code, DateTime month) {
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

String _incomeCardSubtitle(String code, int day) {
  switch (code) {
    case 'en':
      return 'Day $day · Extra income';
    case 'ru':
      return '$day-й день · Доп. доход';
    case 'tr':
    default:
      return '$day. gün · Ek gelir';
  }
}

String _extraIncomeMonthSubtitle(String code, String month) {
  switch (code) {
    case 'en':
      return 'Extra income records in $month';
    case 'ru':
      return 'Записи доп. доходов за $month';
    case 'tr':
    default:
      return '$month içindeki ek gelir kayıtları';
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

String _incomeDayText(String code, int day) {
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

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({
    required this.income,
    required this.onTap,
  });

  final IncomeItem income;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = PlanoraScope.of(context).appLanguageCode;

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: income.color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${income.day}',
                  style: TextStyle(
                    color: income.color,
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
                  Text(income.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    _incomeCardSubtitle(lang, income.day),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              '+ ${MoneyFormatter.format(income.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.brandGreen,
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? prefix;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        prefixText: prefix,
        filled: true,
        fillColor: AppColors.softBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.4),
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
