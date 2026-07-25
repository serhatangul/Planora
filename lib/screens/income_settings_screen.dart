import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class IncomeSettingsScreen extends StatefulWidget {
  const IncomeSettingsScreen({super.key});

  @override
  State<IncomeSettingsScreen> createState() => _IncomeSettingsScreenState();
}

class _IncomeSettingsScreenState extends State<IncomeSettingsScreen> {
  final _incomeController = TextEditingController();
  final _savingTargetController = TextEditingController();
  final _currentSavingController = TextEditingController();
  final _salaryDayController = TextEditingController();

  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;

    final controller = PlanoraScope.of(context);
    _incomeController.text = controller.monthlyIncome.round().toString();
    _savingTargetController.text = controller.savingTarget.round().toString();
    _currentSavingController.text = controller.currentSaving.round().toString();
    _salaryDayController.text = controller.salaryDay.toString();

    _didInit = true;
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingTargetController.dispose();
    _currentSavingController.dispose();
    _salaryDayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final lang = PlanoraScope.of(context).appLanguageCode;
    final income = MoneyFormatter.parseAmount(_incomeController.text);
    final target = MoneyFormatter.parseAmount(_savingTargetController.text);
    final current = MoneyFormatter.parseAmount(_currentSavingController.text);
    final salaryDay = int.tryParse(_salaryDayController.text.trim()) ?? 1;

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_incomeSettingsText(lang, 'invalidIncome'))),
      );
      return;
    }

    await PlanoraScope.of(context).updateFinancialSettings(
      newMonthlyIncome: income,
      newSavingTarget: target,
      newCurrentSaving: current,
      newSalaryDay: salaryDay,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = PlanoraScope.of(context).appLanguageCode;

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
                    _incomeSettingsText(lang, 'title'),
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
                    label: _incomeSettingsText(lang, 'monthlyIncome'),
                    controller: _incomeController,
                    icon: Icons.account_balance_wallet_rounded,
                    prefix: MoneyFormatter.currencySymbol,
                  ),
                  const SizedBox(height: 16),
                  _InputField(
                    label: _incomeSettingsText(lang, 'savingTarget'),
                    controller: _savingTargetController,
                    icon: Icons.savings_rounded,
                    prefix: MoneyFormatter.currencySymbol,
                  ),
                  const SizedBox(height: 16),
                  _InputField(
                    label: _incomeSettingsText(lang, 'currentSaving'),
                    controller: _currentSavingController,
                    icon: Icons.trending_up_rounded,
                    prefix: MoneyFormatter.currencySymbol,
                  ),
                  const SizedBox(height: 16),
                  _InputField(
                    label: _incomeSettingsText(lang, 'salaryDay'),
                    controller: _salaryDayController,
                    icon: Icons.event_available_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PremiumCard(
              color: const Color(0xFFF9FBFF),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _incomeSettingsText(lang, 'infoNote'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: _incomeSettingsText(lang, 'saveIncome'),
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}


String _incomeSettingsText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidIncome': {
      'tr': 'Lütfen geçerli bir aylık gelir gir.',
      'en': 'Please enter a valid monthly income.',
      'ru': 'Введите корректный месячный доход.',
    },
    'title': {
      'tr': 'Gelir ayarları',
      'en': 'Income settings',
      'ru': 'Настройки дохода',
    },
    'monthlyIncome': {
      'tr': 'Aylık gelir',
      'en': 'Monthly income',
      'ru': 'Месячный доход',
    },
    'savingTarget': {
      'tr': 'Birikim hedefi',
      'en': 'Saving target',
      'ru': 'Цель накоплений',
    },
    'currentSaving': {
      'tr': 'Mevcut birikim',
      'en': 'Current saving',
      'ru': 'Текущие накопления',
    },
    'salaryDay': {
      'tr': 'Maaş günü',
      'en': 'Salary day',
      'ru': 'День зарплаты',
    },
    'infoNote': {
      'tr': 'Maaş günü, güvenli günlük harcama limitinin bir sonraki maaşa kadar hesaplanmasını sağlar.',
      'en': 'Salary day helps calculate the safe daily spending limit until your next salary.',
      'ru': 'День зарплаты помогает рассчитать безопасный дневной лимит расходов до следующей зарплаты.',
    },
    'saveIncome': {
      'tr': 'Geliri Kaydet',
      'en': 'Save Income',
      'ru': 'Сохранить доход',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
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
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
