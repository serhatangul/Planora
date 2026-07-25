import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class EditPaymentScreen extends StatefulWidget {
  const EditPaymentScreen({
    super.key,
    required this.paymentId,
  });

  final String paymentId;

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();

  String? _category;
  bool _isMonthly = true;
  bool _didInit = false;

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

    final currentOffset = _titleController.selection.baseOffset;
    final safeOffset = currentOffset < 0
        ? updatedText.length
        : currentOffset.clamp(0, updatedText.length).toInt();

    _isCapitalizingTitle = true;
    _titleController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: safeOffset),
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;

    final payment = PlanoraScope.of(context).paymentById(widget.paymentId);
    if (payment != null) {
      _titleController.text = payment.title;
      _amountController.text = payment.amount.round().toString();
      _dayController.text = payment.dueDay.toString();
      _category = payment.category;
      _isMonthly = payment.isMonthly;
    }

    _didInit = true;
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
    final selectedCategory = _category ?? (categories.isNotEmpty ? categories.first : _editPaymentText(lang, 'otherCategory'));

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editPaymentText(lang, 'invalidPayment'))),
      );
      return;
    }

    await controller.updatePayment(
      id: widget.paymentId,
      title: title,
      category: selectedCategory,
      amount: amount,
      dueDay: dueDay,
      isMonthly: _isMonthly,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await PlanoraScope.of(context).removePayment(widget.paymentId);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lang = controller.appLanguageCode;
        final categories = controller.categories;
        final selectedCategory = categories.contains(_category)
            ? _category
            : categories.isNotEmpty
                ? categories.first
                : null;

        return Scaffold(
          backgroundColor: AppColors.softBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
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
                        _editPaymentText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    children: [
                      _InputField(
                        label: _editPaymentText(lang, 'paymentName'),
                        controller: _titleController,
                        icon: Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 16),
                      _InputField(
                        label: _editPaymentText(lang, 'amount'),
                        controller: _amountController,
                        icon: Icons.payments_rounded,
                        keyboardType: TextInputType.number,
                        prefix: controller.currencySymbol,
                      ),
                      const SizedBox(height: 16),
                      _InputField(
                        label: _editPaymentText(lang, 'dayOfMonth'),
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
                          label: _editPaymentText(lang, 'category'),
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
                const SizedBox(height: 22),
                SectionHeader(title: _editPaymentText(lang, 'repeat')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ToggleOption(
                        label: _editPaymentText(lang, 'monthly'),
                        active: _isMonthly,
                        onTap: () => setState(() => _isMonthly = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ToggleOption(
                        label: _editPaymentText(lang, 'oneTime'),
                        active: !_isMonthly,
                        onTap: () => setState(() => _isMonthly = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isMonthly
                              ? _editPaymentText(lang, 'monthlyInfo')
                              : _editPaymentText(lang, 'oneTimeInfo'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: _editPaymentText(lang, 'saveChanges'),
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_rounded, color: AppColors.danger),
                  label: Text(
                    _editPaymentText(lang, 'deletePayment'),
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
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


String _editPaymentText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidPayment': {
      'tr': 'Lütfen geçerli ödeme bilgileri gir.',
      'en': 'Please enter valid payment details.',
      'ru': 'Введите корректные данные платежа.',
    },
    'title': {
      'tr': 'Ödemeyi düzenle',
      'en': 'Edit payment',
      'ru': 'Редактировать платёж',
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
      'tr': 'Tek sefer seçilirse ödeme sadece bu ödeme ayına ait görünür.',
      'en': 'If one-time is selected, the payment appears only in this payment month.',
      'ru': 'Если выбран разовый платёж, он появится только в месяце этого платежа.',
    },
    'saveChanges': {
      'tr': 'Değişiklikleri Kaydet',
      'en': 'Save Changes',
      'ru': 'Сохранить изменения',
    },
    'deletePayment': {
      'tr': 'Ödemeyi Sil',
      'en': 'Delete Payment',
      'ru': 'Удалить платёж',
    },
    'otherCategory': {
      'tr': 'Diğer',
      'en': 'Other',
      'ru': 'Другое',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
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
    return TextField(
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
