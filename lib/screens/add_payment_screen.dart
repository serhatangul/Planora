import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({
    super.key,
    required this.onSaved,
  });

  final VoidCallback onSaved;

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController(text: '15');

  String? _category;
  bool _isCapitalizingTitle = false;

  void _capitalizeTitleInput() {
    if (_isCapitalizingTitle) return;

    final text = _titleController.text;
    if (text.isEmpty) return;

    final firstLetterIndex = text.indexOf(RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]'));
    if (firstLetterIndex == -1) return;

    final firstLetter = text[firstLetterIndex];
    final upperFirstLetter = firstLetter.toUpperCase();

    if (firstLetter == upperFirstLetter) return;

    final updatedText =
        text.substring(0, firstLetterIndex) +
        upperFirstLetter +
        text.substring(firstLetterIndex + 1);

    _isCapitalizingTitle = true;
    _titleController.value = _titleController.value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: _titleController.selection.baseOffset.clamp(0, updatedText.length),
      ),
      composing: TextRange.empty,
    );
    _isCapitalizingTitle = false;
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_capitalizeTitleInput);
  }

  @override
  void dispose() {
    _titleController.removeListener(_capitalizeTitleInput);
    _titleController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;
    final categories = controller.categories;

    final title = _titleController.text.trim();
    final amount = MoneyFormatter.parseAmount(_amountController.text);
    final dueDay = int.tryParse(_dayController.text.trim()) ?? 1;
    final selectedCategory = _category ?? (categories.isNotEmpty ? categories.first : _addPaymentText(lang, 'otherCategory'));

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_addPaymentText(lang, 'invalidPayment'))),
      );
      return;
    }

    await controller.addPayment(
      title: title,
      category: selectedCategory,
      amount: amount,
      dueDay: dueDay,
      isMonthly: true,
    );

    _titleController.clear();
    _amountController.clear();
    _dayController.text = '15';

    if (!mounted) return;
    widget.onSaved();
  }

  Future<void> _addOneTimePayment() async {
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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_addPaymentText(lang, 'oneTimeAdded'))),
    );
  }



  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lang = controller.appLanguageCode;
        final categories = controller.categories;
        final selectedCategory = _category ?? (categories.isNotEmpty ? categories.first : null);

        return Scaffold(
          backgroundColor: AppColors.softBg,
          body: SafeArea(
            bottom: false,
            child: Material(
              type: MaterialType.transparency,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 132),
              children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onSaved,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                    tooltip: _addPaymentText(lang, 'back'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _addPaymentText(lang, 'title'),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_addPaymentText(lang, 'subtitle'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  children: [
                    _InputField(
                      label: _addPaymentText(lang, 'paymentName'),
                      controller: _titleController,
                      icon: Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: _addPaymentText(lang, 'amount'),
                      controller: _amountController,
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      prefix: controller.currencySymbol,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: _addPaymentText(lang, 'dayOfMonth'),
                      controller: _dayController,
                      icon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(controller.categoryLabel(category)),
                              ))
                          .toList(),
                      decoration: _inputDecoration(
                        label: _addPaymentText(lang, 'category'),
                        icon: Icons.category_rounded,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: _addPaymentText(lang, 'savePayment'),
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
              const SizedBox(height: 22),
              PremiumCard(
                color: const Color(0xFFF9FBFF),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add_card_rounded, color: AppColors.brandGreen),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _addPaymentText(lang, 'oneTimeTitle'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _addPaymentText(lang, 'oneTimeSubtitle'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addOneTimePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _addPaymentText(lang, 'oneTimeAdd'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


String _addPaymentText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidPayment': {
      'tr': 'Lütfen geçerli ödeme bilgileri gir.',
      'en': 'Please enter valid payment details.',
      'ru': 'Введите корректные данные платежа.',
    },
    'back': {
      'tr': 'Geri',
      'en': 'Back',
      'ru': 'Назад',
    },
    'title': {
      'tr': 'Aylık ödeme',
      'en': 'Monthly payment',
      'ru': 'Ежемесячный платёж',
    },
    'subtitle': {
      'tr': 'Kira, kredi, fatura gibi her ay tekrar eden ödemeleri ekle.',
      'en': 'Add recurring payments such as rent, loans, or bills.',
      'ru': 'Добавьте регулярные платежи: аренду, кредиты или счета.',
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
    'dayOfMonth': {
      'tr': 'Ayın kaçıncı günü?',
      'en': 'Day of the month?',
      'ru': 'День месяца?',
    },
    'category': {
      'tr': 'Kategori',
      'en': 'Category',
      'ru': 'Категория',
    },
    'repeat': {
      'tr': 'Tekrar',
      'en': 'Repeat',
      'ru': 'Повтор',
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
    'monthlyInfo': {
      'tr': 'Aylık seçilirse ödeme her ay takvimde görünür.',
      'en': 'If monthly is selected, the payment appears on the calendar every month.',
      'ru': 'Если выбран ежемесячный платёж, он будет появляться в календаре каждый месяц.',
    },
    'oneTimeInfo': {
      'tr': 'Tek sefer seçilirse ödeme sadece seçili ayda görünür.',
      'en': 'If one-time is selected, the payment appears only in the selected month.',
      'ru': 'Если выбран разовый платёж, он появится только в выбранном месяце.',
    },
    'savePayment': {
      'tr': 'Ödemeyi Kaydet',
      'en': 'Save Payment',
      'ru': 'Сохранить платёж',
    },
    'oneTimeTitle': {
      'tr': 'Tek seferlik harcama',
      'en': 'One-time expense',
      'ru': 'Разовый расход',
    },
    'oneTimeSubtitle': {
      'tr': 'Bugüne Diğer kategorisinde harcama ekle.',
      'en': 'Add an expense for today under Other.',
      'ru': 'Добавить расход на сегодня в категорию Другое.',
    },
    'oneTimeAdd': {
      'tr': 'Ekle',
      'en': 'Add',
      'ru': 'Добавить',
    },
    'oneTimeDialogTitle': {
      'tr': 'Tek seferlik harcama',
      'en': 'One-time expense',
      'ru': 'Разовый расход',
    },
    'oneTimeAdded': {
      'tr': 'Tek seferlik harcama bugüne Diğer kategorisiyle eklendi.',
      'en': 'One-time expense added for today under Other.',
      'ru': 'Разовый расход добавлен на сегодня в категорию Другое.',
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
    'otherCategory': {
      'tr': 'Diğer',
      'en': 'Other',
      'ru': 'Другое',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
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
      title: Text(_addPaymentText(widget.lang, 'oneTimeDialogTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _addPaymentText(widget.lang, 'paymentName'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: _addPaymentText(widget.lang, 'amount'),
              prefixText: '${widget.currencySymbol} ',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_addPaymentText(widget.lang, 'cancel')),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(_addPaymentText(widget.lang, 'add')),
        ),
      ],
    );
  }
}


class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.prefix,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: _inputDecoration(label: label, icon: icon, prefix: prefix),
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? prefix,
}) {
  return InputDecoration(
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
  );
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      color: active ? const Color(0xFFE8FFF6) : Colors.white,
      borderColor: active ? AppColors.brandGreen : AppColors.stroke,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF0A7A59) : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
