import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key});

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  final _incomeController = TextEditingController(text: '45000');
  final _savingTargetController = TextEditingController(text: '10000');
  final _currentSavingController = TextEditingController(text: '0');
  final _salaryDayController = TextEditingController(text: '1');

  String _selectedLanguage = 'tr';
  String _selectedCurrency = '₺';
  bool _didInitPreferences = false;

  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitPreferences) return;

    final controller = PlanoraScope.of(context);
    _selectedLanguage = controller.appLanguageCode;
    _selectedCurrency = controller.currencySymbol;
    MoneyFormatter.setCurrencySymbol(_selectedCurrency);
    _didInitPreferences = true;
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingTargetController.dispose();
    _currentSavingController.dispose();
    _salaryDayController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 3) {
      if (!_validateSetup()) return;
      setState(() => _page = 4);
      return;
    }

    if (_page < 4) {
      setState(() => _page++);
      return;
    }

    _finish();
  }

  bool _validateSetup() {
    final lang = _selectedLanguage;
    final income = MoneyFormatter.parseAmount(_incomeController.text);

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_onboardingText(lang, 'invalidIncome'))),
      );
      setState(() => _page = 2);
      return false;
    }

    return true;
  }

  void _back() {
    if (_page == 0) return;
    setState(() => _page--);
  }

  Future<void> _skip() async {
    final controller = PlanoraScope.of(context);
    await controller.updateLanguagePreference(_selectedLanguage);
    await controller.updateCurrencySymbol(_selectedCurrency);
    await controller.markOnboardingCompleted();
  }

  Future<void> _finish() async {
    final lang = _selectedLanguage;
    final income = MoneyFormatter.parseAmount(_incomeController.text);
    final target = MoneyFormatter.parseAmount(_savingTargetController.text);
    final current = MoneyFormatter.parseAmount(_currentSavingController.text);
    final salaryDay = int.tryParse(_salaryDayController.text.trim()) ?? 1;

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_onboardingText(lang, 'invalidIncome'))),
      );
      setState(() => _page = 2);
      return;
    }

    await PlanoraScope.of(context).completeOnboarding(
      newMonthlyIncome: income,
      newSavingTarget: target,
      newCurrentSaving: current,
      newSalaryDay: salaryDay,
      newAppLanguageCode: _selectedLanguage,
      newCurrencySymbol: _selectedCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = PlanoraScope.of(context).appLanguageCode;

    final pages = [
      _SetupPage(
        lang: lang,
        selectedLanguage: _selectedLanguage,
        selectedCurrency: _selectedCurrency,
        onLanguageChanged: (value) async {
          setState(() => _selectedLanguage = value);
          await PlanoraScope.of(context).updateLanguagePreference(value);
        },
        onCurrencyChanged: (value) async {
          setState(() => _selectedCurrency = value);
          MoneyFormatter.setCurrencySymbol(value);
          await PlanoraScope.of(context).updateCurrencySymbol(value);
        },
      ),
      _IntroPage(lang: lang, onSkip: _skip),
      _FinancePage(
        lang: lang,
        currencySymbol: _selectedCurrency,
        incomeController: _incomeController,
        salaryDayController: _salaryDayController,
      ),
      _SavingPage(
        lang: lang,
        currencySymbol: _selectedCurrency,
        savingTargetController: _savingTargetController,
        currentSavingController: _currentSavingController,
      ),
      _ReadyPage(
        lang: lang,
        selectedLanguage: _selectedLanguage,
        selectedCurrency: _selectedCurrency,
        incomeController: _incomeController,
        salaryDayController: _salaryDayController,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const PlanoraLogo(size: 44, showText: true),
                  const Spacer(),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      _onboardingText(lang, 'skip'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: List.generate(5, (index) {
                  final active = index <= _page;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.brandGreen : AppColors.stroke,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: pages[_page],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _back,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.stroke),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            _onboardingText(lang, 'back'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: _page == 4 ? _onboardingText(lang, 'goDashboard') : (_page == 3 ? _onboardingText(lang, 'createPlan') : _onboardingText(lang, 'continue')),
                      icon: _page == 4 ? Icons.dashboard_customize_rounded : (_page == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded),
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SetupPage extends StatelessWidget {
  const _SetupPage({
    required this.lang,
    required this.selectedLanguage,
    required this.selectedCurrency,
    required this.onLanguageChanged,
    required this.onCurrencyChanged,
  });

  final String lang;
  final String selectedLanguage;
  final String selectedCurrency;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final languages = [
      _SetupOption(
        value: 'tr',
        title: 'Türkçe',
        subtitle: 'Türkiye',
        icon: Icons.language_rounded,
      ),
      _SetupOption(
        value: 'en',
        title: 'English',
        subtitle: 'United States / Global',
        icon: Icons.language_rounded,
      ),
      _SetupOption(
        value: 'ru',
        title: 'Русский',
        subtitle: 'Россия / СНГ',
        icon: Icons.language_rounded,
      ),
    ];

    final currencies = [
      _SetupOption(value: '₺', title: '₺ TRY', subtitle: 'Türk Lirası', icon: Icons.payments_rounded),
      _SetupOption(value: '₽', title: '₽ RUB', subtitle: 'Russian Ruble', icon: Icons.payments_rounded),
      _SetupOption(value: r'$', title: r'$ USD', subtitle: 'US Dollar', icon: Icons.payments_rounded),
      _SetupOption(value: '€', title: '€ EUR', subtitle: 'Euro', icon: Icons.payments_rounded),
      _SetupOption(value: '£', title: '£ GBP', subtitle: 'British Pound', icon: Icons.payments_rounded),
    ];

    return ListView(
      key: const ValueKey('setup'),
      children: [
        Text(_onboardingText(lang, 'setupTitle'), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          _onboardingText(lang, 'setupSubtitle'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          _onboardingText(lang, 'chooseLanguage'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...languages.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SetupChoiceCard(
              option: item,
              isSelected: selectedLanguage == item.value,
              onTap: () => onLanguageChanged(item.value),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _onboardingText(lang, 'chooseCurrency'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...currencies.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SetupChoiceCard(
              option: item,
              isSelected: selectedCurrency == item.value,
              onTap: () => onCurrencyChanged(item.value),
            ),
          ),
        ),
      ],
    );
  }
}

class _SetupOption {
  const _SetupOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _SetupChoiceCard extends StatelessWidget {
  const _SetupChoiceCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _SetupOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.brandGreen : AppColors.textSecondary;

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      borderColor: isSelected ? AppColors.brandGreen.withOpacity(0.45) : AppColors.stroke,
      color: isSelected ? const Color(0xFFF2FFF8) : Colors.white,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandGreen.withOpacity(0.14) : AppColors.softBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(option.icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(option.subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: color,
          ),
        ],
      ),
    );
  }
}


class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.lang, required this.onSkip});

  final String lang;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('intro'),
      children: [
        const SizedBox(height: 24),
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: AppGradients.premiumDark,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkNavy.withOpacity(0.20),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -20,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 76,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _onboardingText(lang, 'introTitle'),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          _onboardingText(lang, 'introSubtitle'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),
        _BenefitRow(
          icon: Icons.calendar_month_rounded,
          title: _onboardingText(lang, 'monthlyTracking'),
          subtitle: _onboardingText(lang, 'monthlyTrackingSubtitle'),
        ),
        const SizedBox(height: 14),
        _BenefitRow(
          icon: Icons.notifications_active_rounded,
          title: _onboardingText(lang, 'smartAlerts'),
          subtitle: _onboardingText(lang, 'smartAlertsSubtitle'),
        ),
        const SizedBox(height: 14),
        _BenefitRow(
          icon: Icons.savings_rounded,
          title: _onboardingText(lang, 'safeSpendingLimit'),
          subtitle: _onboardingText(lang, 'safeSpendingLimitSubtitle'),
        ),
      ],
    );
  }
}

class _FinancePage extends StatelessWidget {
  const _FinancePage({
    required this.lang,
    required this.currencySymbol,
    required this.incomeController,
    required this.salaryDayController,
  });

  final String lang;
  final String currencySymbol;
  final TextEditingController incomeController;
  final TextEditingController salaryDayController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('finance'),
      children: [
        Text(_onboardingText(lang, 'financeTitle'), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          _onboardingText(lang, 'financeSubtitle'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        PremiumCard(
          child: Column(
            children: [
              _InputField(
                label: _onboardingText(lang, 'monthlyIncome'),
                controller: incomeController,
                icon: Icons.account_balance_wallet_rounded,
                prefix: currencySymbol,
              ),
              const SizedBox(height: 16),
              _InputField(
                label: _onboardingText(lang, 'salaryDay'),
                controller: salaryDayController,
                icon: Icons.event_available_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SavingPage extends StatelessWidget {
  const _SavingPage({
    required this.lang,
    required this.currencySymbol,
    required this.savingTargetController,
    required this.currentSavingController,
  });

  final String lang;
  final String currencySymbol;
  final TextEditingController savingTargetController;
  final TextEditingController currentSavingController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('saving'),
      children: [
        Text(_onboardingText(lang, 'savingTitle'), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          _onboardingText(lang, 'savingSubtitle'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        PremiumCard(
          child: Column(
            children: [
              _InputField(
                label: _onboardingText(lang, 'savingTarget'),
                controller: savingTargetController,
                icon: Icons.savings_rounded,
                prefix: currencySymbol,
              ),
              const SizedBox(height: 16),
              _InputField(
                label: _onboardingText(lang, 'currentSaving'),
                controller: currentSavingController,
                icon: Icons.trending_up_rounded,
                prefix: currencySymbol,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PremiumCard(
          color: const Color(0xFFF9FBFF),
          child: Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.brandBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _onboardingText(lang, 'laterChangeNote'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


String _onboardingText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'invalidIncome': {'tr': 'Lütfen geçerli bir aylık gelir gir.', 'en': 'Please enter a valid monthly income.', 'ru': 'Введите корректный месячный доход.'},
    'setupTitle': {'tr': 'Başlamadan önce', 'en': 'Before we start', 'ru': 'Перед началом'},
    'setupSubtitle': {'tr': 'Planora’yı kullanacağın dile ve para birimine göre ayarlayalım.', 'en': 'Choose the language and currency you want to use in Planora.', 'ru': 'Выберите язык и валюту для использования Planora.'},
    'chooseLanguage': {'tr': 'Dil seçimi', 'en': 'Language', 'ru': 'Язык'},
    'chooseCurrency': {'tr': 'Para birimi', 'en': 'Currency', 'ru': 'Валюта'},
    'skip': {'tr': 'Geç', 'en': 'Skip', 'ru': 'Пропустить'},
    'back': {'tr': 'Geri', 'en': 'Back', 'ru': 'Назад'},
    'createPlan': {'tr': 'Planımı Oluştur', 'en': 'Create My Plan', 'ru': 'Создать план'},
    'continue': {'tr': 'Devam Et', 'en': 'Continue', 'ru': 'Продолжить'},
    'goDashboard': {'tr': 'Başla', 'en': 'Start', 'ru': 'Готово'},
    'readyTitle': {'tr': 'Planora hazır', 'en': 'Planora is ready', 'ru': 'Planora готова'},
    'readySubtitle': {'tr': 'Bütçe sistemin oluşturuldu. Şimdi gelirini, ödemelerini ve harcamalarını tek yerden takip edebilirsin.', 'en': 'Your budget system has been prepared. You can now track income, payments, and expenses in one place.', 'ru': 'Ваша бюджетная система готова. Теперь вы можете отслеживать доходы, платежи и расходы в одном месте.'},
    'readyLanguage': {'tr': 'Dil', 'en': 'Language', 'ru': 'Язык'},
    'readyCurrency': {'tr': 'Para birimi', 'en': 'Currency', 'ru': 'Валюта'},
    'readyIncome': {'tr': 'Aylık gelir', 'en': 'Monthly income', 'ru': 'Месячный доход'},
    'readySalaryDay': {'tr': 'Maaş günü', 'en': 'Salary day', 'ru': 'День зарплаты'},
    'readySalaryDayValue': {'tr': 'Her ay {day}. gün', 'en': 'Day {day} monthly', 'ru': '{day}-й день'},
    'readyNote': {'tr': 'Sonraki adım: ilk sabit ödemeni ve ilk harcamanı ekleyerek Dashboard’u gerçek verilerle doldur.', 'en': 'Next step: add your first fixed payment and first expense to fill the dashboard with real data.', 'ru': 'Следующий шаг: добавьте первый регулярный платёж и первый расход, чтобы заполнить панель реальными данными.'},
    'introTitle': {'tr': 'Planora’yı sana göre ayarlayalım', 'en': 'Let’s set up Planora for you', 'ru': 'Настроим Planora под вас'},
    'introSubtitle': {'tr': 'Aylık gelirini, maaş gününü ve birikim hedefini girerek daha gerçekçi bir finans planı oluşturabilirsin.', 'en': 'Enter your monthly income, salary day, and saving target to create a more realistic financial plan.', 'ru': 'Введите месячный доход, день зарплаты и цель накоплений, чтобы создать более реалистичный финансовый план.'},
    'monthlyTracking': {'tr': 'Ay bazlı takip', 'en': 'Monthly tracking', 'ru': 'Учёт по месяцам'},
    'monthlyTrackingSubtitle': {'tr': 'Ödemeler her ay doğru şekilde hesaplanır.', 'en': 'Payments are calculated correctly each month.', 'ru': 'Платежи корректно рассчитываются каждый месяц.'},
    'smartAlerts': {'tr': 'Akıllı uyarılar', 'en': 'Smart alerts', 'ru': 'Умные уведомления'},
    'smartAlertsSubtitle': {'tr': 'Geciken ve yaklaşan ödemeler görünür.', 'en': 'Late and upcoming payments are visible.', 'ru': 'Видны просроченные и предстоящие платежи.'},
    'safeSpendingLimit': {'tr': 'Güvenli harcama limiti', 'en': 'Safe spending limit', 'ru': 'Безопасный лимит расходов'},
    'safeSpendingLimitSubtitle': {'tr': 'Bir sonraki maaşa kadar günlük limit hesaplanır.', 'en': 'A daily limit is calculated until your next salary day.', 'ru': 'Дневной лимит рассчитывается до следующей зарплаты.'},
    'financeTitle': {'tr': 'Gelir bilgileri', 'en': 'Income details', 'ru': 'Данные о доходе'},
    'financeSubtitle': {'tr': 'Bu bilgiler ana paneldeki kalan bakiye ve güvenli harcama limitini hesaplamak için kullanılır.', 'en': 'This information is used to calculate the remaining balance and safe spending limit on the main dashboard.', 'ru': 'Эти данные используются для расчёта остатка и безопасного лимита расходов на главной панели.'},
    'monthlyIncome': {'tr': 'Aylık gelir', 'en': 'Monthly income', 'ru': 'Месячный доход'},
    'salaryDay': {'tr': 'Maaş günü', 'en': 'Salary day', 'ru': 'День зарплаты'},
    'savingTitle': {'tr': 'Birikim hedefi', 'en': 'Saving target', 'ru': 'Цель накоплений'},
    'savingSubtitle': {'tr': 'Birikim hedefin, serbest bakiyenin daha kontrollü hesaplanmasına yardımcı olur.', 'en': 'Your saving target helps calculate your free balance more carefully.', 'ru': 'Цель накоплений помогает точнее рассчитывать свободный баланс.'},
    'savingTarget': {'tr': 'Birikim hedefi', 'en': 'Saving target', 'ru': 'Цель накоплений'},
    'currentSaving': {'tr': 'Mevcut birikim', 'en': 'Current saving', 'ru': 'Текущие накопления'},
    'laterChangeNote': {'tr': 'Bu ayarları daha sonra Profil > Aylık gelir bölümünden değiştirebilirsin.', 'en': 'You can change these settings later from Profile > Monthly income.', 'ru': 'Эти настройки можно изменить позже в Профиль > Месячный доход.'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}


class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.lang,
    required this.selectedLanguage,
    required this.selectedCurrency,
    required this.incomeController,
    required this.salaryDayController,
  });

  final String lang;
  final String selectedLanguage;
  final String selectedCurrency;
  final TextEditingController incomeController;
  final TextEditingController salaryDayController;

  @override
  Widget build(BuildContext context) {
    final income = MoneyFormatter.format(MoneyFormatter.parseAmount(incomeController.text));
    final salaryDay = salaryDayController.text.trim().isEmpty ? '1' : salaryDayController.text.trim();

    return ListView(
      key: const ValueKey('ready'),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppGradients.premiumDark,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkNavy.withOpacity(0.22),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.brandGreen,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _onboardingText(lang, 'readyTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _onboardingText(lang, 'readySubtitle'),
                style: const TextStyle(
                  color: Color(0xFFC8D3FF),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PremiumCard(
          child: Column(
            children: [
              _ReadySummaryRow(
                icon: Icons.language_rounded,
                label: _onboardingText(lang, 'readyLanguage'),
                value: _languageName(selectedLanguage),
              ),
              const SizedBox(height: 14),
              _ReadySummaryRow(
                icon: Icons.payments_rounded,
                label: _onboardingText(lang, 'readyCurrency'),
                value: selectedCurrency,
              ),
              const SizedBox(height: 14),
              _ReadySummaryRow(
                icon: Icons.account_balance_wallet_rounded,
                label: _onboardingText(lang, 'readyIncome'),
                value: income,
              ),
              const SizedBox(height: 14),
              _ReadySummaryRow(
                icon: Icons.event_available_rounded,
                label: _onboardingText(lang, 'readySalaryDay'),
                value: _onboardingText(lang, 'readySalaryDayValue').replaceAll('{day}', salaryDay),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PremiumCard(
          color: const Color(0xFFF4FFFB),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.brandGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _onboardingText(lang, 'readyNote'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _languageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'tr':
      default:
        return 'Türkçe';
    }
  }
}

class _ReadySummaryRow extends StatelessWidget {
  const _ReadySummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppColors.brandBlue),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.brandGreen),
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
        ],
      ),
    );
  }
}
