import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';
import 'category_settings_screen.dart';
import 'income_settings_screen.dart';
import 'help_guide_screen.dart';
import 'backup_restore_screen.dart';
import 'about_data_safety_screen.dart';
import 'data_management_screen.dart';
import 'currency_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'theme_preference_screen.dart';
import 'language_preference_screen.dart';
import 'notification_preferences_screen.dart';
import 'monthly_timeline_screen.dart';
import 'expenses_screen.dart';
import 'extra_income_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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


  void _openAboutDataSafety(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const AboutDataSafetyScreen(),
        ),
      ),
    );
  }

  void _openLanguagePreference(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const LanguagePreferenceScreen(),
        ),
      ),
    );
  }

  void _openThemePreference(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const ThemePreferenceScreen(),
        ),
      ),
    );
  }

  void _openHelpGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const HelpGuideScreen(),
        ),
      ),
    );
  }

  void _openNotificationPreferences(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const NotificationPreferencesScreen(),
        ),
      ),
    );
  }

  void _openPrivacySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const PrivacySettingsScreen(),
        ),
      ),
    );
  }

  void _openCurrencySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const CurrencySettingsScreen(),
        ),
      ),
    );
  }

  void _openDataManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const DataManagementScreen(),
        ),
      ),
    );
  }

  void _openBackupRestore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const BackupRestoreScreen(),
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

  void _openCategorySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: const CategorySettingsScreen(),
        ),
      ),
    );
  }

  Future<void> _resetData(BuildContext context) async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_profileText(lang, 'clearAllDataDialogTitle')),
          content: Text(_profileText(lang, 'clearAllDataDialogDescription')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_profileText(lang, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                _profileText(lang, 'clearAllDataConfirm'),
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await controller.resetToDefaults();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_profileText(lang, 'clearAllDataDone'))),
    );
  }

  Future<void> _restartOnboarding(BuildContext context) async {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_restartOnboardingDialogTitle(lang)),
          content: Text(_restartOnboardingDialogDescription(lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_profileText(lang, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                _restartOnboardingConfirmLabel(lang),
                style: const TextStyle(
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await controller.resetOnboarding();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_restartOnboardingDoneMessage(lang))),
    );
  }


  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final setupItems = [
          _ProfileItem(
            title: _profileText(lang, 'language'),
            subtitle: _languageLabel(controller.appLanguageCode, lang),
            icon: Icons.language_rounded,
            onTap: () => _openLanguagePreference(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'currency'),
            subtitle: _currencySubtitle(lang, controller.currencySymbol),
            icon: Icons.attach_money_rounded,
            onTap: () => _openCurrencySettings(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'monthlyIncome'),
            subtitle: MoneyFormatter.format(controller.monthlyIncome),
            icon: Icons.account_balance_wallet_rounded,
            onTap: () => _openIncomeSettings(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'salaryDay'),
            subtitle: _salaryDaySubtitle(lang, controller.salaryDay),
            icon: Icons.calendar_today_rounded,
            onTap: () => _openIncomeSettings(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'theme'),
            subtitle: controller.preferDarkMode ? _profileText(lang, 'themeDarkSelected') : _profileText(lang, 'themeLightSelected'),
            icon: controller.preferDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            onTap: () => _openThemePreference(context),
          ),
        ];

        final financeItems = [
          _ProfileItem(
            title: _profileText(lang, 'editCategories'),
            subtitle: _categoriesSubtitle(lang, controller.categories.length),
            icon: Icons.category_rounded,
            onTap: () => _openCategorySettings(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'notifications'),
            subtitle: _notificationCountSubtitle(lang, controller.activeNotificationPreferenceCount),
            icon: Icons.notifications_rounded,
            onTap: () => _openNotificationPreferences(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'smartAlerts'),
            subtitle: _profileText(lang, 'smartAlertsActive'),
            icon: Icons.notifications_active_rounded,
          ),
          _ProfileItem(
            title: _profileText(lang, 'extraIncome'),
            subtitle: _recordsMoneySubtitle(lang, controller.extraIncomeCount, MoneyFormatter.format(controller.extraIncomeTotal)),
            icon: Icons.add_chart_rounded,
            onTap: () => _openExtraIncomeScreen(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'expenseRecords'),
            subtitle: _recordsMoneySubtitle(lang, controller.expenseCount, MoneyFormatter.format(controller.expensesTotal)),
            icon: Icons.shopping_bag_rounded,
            onTap: () => _openExpensesScreen(context),
          ),
        ];

        final privacyItems = [
          _ProfileItem(
            title: _profileText(lang, 'privacy'),
            subtitle: controller.hideAmounts ? _profileText(lang, 'amountsHidden') : _profileText(lang, 'amountsVisible'),
            icon: controller.hideAmounts ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            onTap: () => _openPrivacySettings(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'dataManagement'),
            subtitle: _profileText(lang, 'dataManagementSubtitle'),
            icon: Icons.cleaning_services_rounded,
            onTap: () => _openDataManagement(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'backupRestore'),
            subtitle: _profileText(lang, 'backupRestoreSubtitle'),
            icon: Icons.backup_rounded,
            onTap: () => _openBackupRestore(context),
          ),
        ];

        final supportItems = [
          _ProfileItem(
            title: _profileText(lang, 'helpGuide'),
            subtitle: _profileText(lang, 'helpGuideSubtitle'),
            icon: Icons.auto_stories_rounded,
            onTap: () => _openHelpGuide(context),
          ),
          _ProfileItem(
            title: _profileText(lang, 'about'),
            subtitle: _profileText(lang, 'aboutSubtitle'),
            icon: Icons.info_rounded,
            onTap: () => _openAboutDataSafety(context),
          ),
        ];

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 132),
            children: [
              Text(_profileText(lang, 'title'), style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              PremiumCard(
                child: Row(
                  children: [
                    const PlanoraLogo(size: 58),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_profileText(lang, 'planoraUser'), style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            _profileText(lang, 'monthlyPlanActive'),
                            style: const TextStyle(
                              color: AppColors.brandGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ProfileSection(
                title: _profileText(lang, 'setupSection'),
                children: setupItems,
              ),
              const SizedBox(height: 18),
              _ProfileSection(
                title: _profileText(lang, 'financeSection'),
                children: financeItems,
              ),
              const SizedBox(height: 18),
              _ProfileSection(
                title: _profileText(lang, 'privacySection'),
                children: privacyItems,
              ),
              const SizedBox(height: 18),
              _ProfileSection(
                title: _profileText(lang, 'supportSection'),
                children: supportItems,
              ),
              const SizedBox(height: 18),
              _AdvancedActionsSection(
                title: _profileText(lang, 'advancedActions'),
                restartTitle: _profileText(lang, 'restartOnboarding'),
                clearTitle: _profileText(lang, 'clearAllData'),
                onRestart: () => _restartOnboarding(context),
                onClear: () => _resetData(context),
              ),
            ],
          ),
        );
      },
    );
  }
}


String _restartOnboardingDialogTitle(String code) {
  switch (code) {
    case 'en':
      return 'Open initial setup again?';
    case 'ru':
      return 'Открыть начальную настройку снова?';
    case 'tr':
    default:
      return 'İlk kurulum tekrar açılsın mı?';
  }
}

String _restartOnboardingDialogDescription(String code) {
  switch (code) {
    case 'en':
      return 'You can edit language, currency, monthly income, and salary day again. Your existing payments, expenses, and extra income will not be deleted.';
    case 'ru':
      return 'Вы сможете снова изменить язык, валюту, ежемесячный доход и день зарплаты. Существующие платежи, расходы и дополнительные доходы не будут удалены.';
    case 'tr':
    default:
      return 'Dil, para birimi, aylık gelir ve maaş günü bilgilerini yeniden düzenleyebilirsin. Mevcut ödemelerin, harcamaların ve ek gelirlerin silinmez.';
  }
}

String _restartOnboardingConfirmLabel(String code) {
  switch (code) {
    case 'en':
      return 'Open Again';
    case 'ru':
      return 'Открыть снова';
    case 'tr':
    default:
      return 'Tekrar Aç';
  }
}

String _restartOnboardingDoneMessage(String code) {
  switch (code) {
    case 'en':
      return 'Initial setup will open again.';
    case 'ru':
      return 'Экран начальной настройки будет открыт снова.';
    case 'tr':
    default:
      return 'İlk kurulum ekranı tekrar açılacak.';
  }
}

String _currencySubtitle(String code, String symbol) {
  switch (code) {
    case 'en':
      return 'Shown with $symbol';
    case 'ru':
      return 'Отображается в $symbol';
    case 'tr':
    default:
      return '$symbol ile gösteriliyor';
  }
}

String _notificationCountSubtitle(String code, int count) {
  switch (code) {
    case 'en':
      return '$count/5 alert types active';
    case 'ru':
      return '$count/5 типов уведомлений активно';
    case 'tr':
    default:
      return '$count/5 uyarı türü aktif';
  }
}

String _recordsMoneySubtitle(String code, int count, String amount) {
  switch (code) {
    case 'en':
      return '$count records · $amount';
    case 'ru':
      return '$count записей · $amount';
    case 'tr':
    default:
      return '$count kayıt · $amount';
  }
}

String _categoriesSubtitle(String code, int count) {
  switch (code) {
    case 'en':
      return '$count categories and limits';
    case 'ru':
      return '$count категорий и лимитов';
    case 'tr':
    default:
      return '$count kategori ve limitler';
  }
}

String _salaryDaySubtitle(String code, int salaryDay) {
  switch (code) {
    case 'en':
      return 'Every month on day $salaryDay';
    case 'ru':
      return 'Каждый месяц, $salaryDay-е число';
    case 'tr':
    default:
      return 'Her ayın $salaryDay’i';
  }
}

String _profileText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Profil',
      'en': 'Profile',
      'ru': 'Профиль',
    },
    'subtitle': {
      'tr': 'Planora ayarları ve kişisel bütçe tercihleri',
      'en': 'Planora settings and personal budget preferences',
      'ru': 'Настройки Planora и параметры личного бюджета',
    },
    'setupSection': {
      'tr': 'Kurulum ve tercihler',
      'en': 'Setup and preferences',
      'ru': 'Настройка и предпочтения',
    },
    'financeSection': {
      'tr': 'Finans yönetimi',
      'en': 'Finance management',
      'ru': 'Управление финансами',
    },
    'privacySection': {
      'tr': 'Gizlilik ve veri',
      'en': 'Privacy and data',
      'ru': 'Конфиденциальность и данные',
    },
    'supportSection': {
      'tr': 'Destek ve uygulama',
      'en': 'Support and app',
      'ru': 'Поддержка и приложение',
    },
    'advancedActions': {
      'tr': 'Gelişmiş işlemler',
      'en': 'Advanced actions',
      'ru': 'Расширенные действия',
    },
    'helpGuide': {
      'tr': 'Kullanım rehberi',
      'en': 'User guide',
      'ru': 'Руководство',
    },
    'helpGuideSubtitle': {
      'tr': 'Planora nasıl kullanılır?',
      'en': 'How to use Planora',
      'ru': 'Как пользоваться Planora',
    },
    'theme': {
      'tr': 'Tema',
      'en': 'Theme',
      'ru': 'Тема',
    },
    'themeDarkSelected': {
      'tr': 'Koyu mod tercihi seçili',
      'en': 'Dark mode preference selected',
      'ru': 'Выбрана тёмная тема',
    },
    'themeLightSelected': {
      'tr': 'Açık mod tercihi seçili',
      'en': 'Light mode preference selected',
      'ru': 'Выбрана светлая тема',
    },
    'language': {
      'tr': 'Dil',
      'en': 'Language',
      'ru': 'Язык',
    },
    'about': {
      'tr': 'Hakkında',
      'en': 'About',
      'ru': 'О приложении',
    },
    'aboutSubtitle': {
      'tr': 'Planora ve veri güvenliği',
      'en': 'Planora and data safety',
      'ru': 'Planora и безопасность данных',
    },
    'monthlyIncome': {
      'tr': 'Aylık gelir',
      'en': 'Monthly income',
      'ru': 'Ежемесячный доход',
    },
    'salaryDay': {
      'tr': 'Maaş günü',
      'en': 'Salary day',
      'ru': 'День зарплаты',
    },
    'salaryDaySubtitle': {
      'tr': 'Aylık döngü başlangıcı',
      'en': 'Monthly cycle start',
      'ru': 'Начало месячного цикла',
    },
    'currency': {
      'tr': 'Para birimi',
      'en': 'Currency',
      'ru': 'Валюта',
    },
    'privacy': {
      'tr': 'Gizlilik',
      'en': 'Privacy',
      'ru': 'Конфиденциальность',
    },
    'amountsHidden': {
      'tr': 'Tutarlar gizleniyor',
      'en': 'Amounts are hidden',
      'ru': 'Суммы скрыты',
    },
    'amountsVisible': {
      'tr': 'Tutarlar görünür',
      'en': 'Amounts are visible',
      'ru': 'Суммы видны',
    },
    'notifications': {
      'tr': 'Bildirimler',
      'en': 'Notifications',
      'ru': 'Уведомления',
    },
    'smartAlerts': {
      'tr': 'Akıllı uyarılar',
      'en': 'Smart alerts',
      'ru': 'Умные уведомления',
    },
    'smartAlertsActive': {
      'tr': 'Uygulama içi akıllı uyarılar aktif',
      'en': 'In-app smart alerts are active',
      'ru': 'Внутренние умные уведомления активны',
    },
    'extraIncome': {
      'tr': 'Ek gelirler',
      'en': 'Extra income',
      'ru': 'Дополнительные доходы',
    },
    'expenseRecords': {
      'tr': 'Harcama kayıtları',
      'en': 'Expense records',
      'ru': 'Записи расходов',
    },
    'editCategories': {
      'tr': 'Kategoriler',
      'en': 'Categories',
      'ru': 'Категории',
    },
    'dataManagement': {
      'tr': 'Veri yönetimi',
      'en': 'Data management',
      'ru': 'Управление данными',
    },
    'dataManagementSubtitle': {
      'tr': 'Seçili ayı veya veri tiplerini temizle',
      'en': 'Clean selected month or data types',
      'ru': 'Очистить выбранный месяц или типы данных',
    },
    'backupRestore': {
      'tr': 'Verileri yedekle',
      'en': 'Backup data',
      'ru': 'Резервное копирование',
    },
    'backupRestoreSubtitle': {
      'tr': 'Dışa aktar veya geri yükle',
      'en': 'Export or restore',
      'ru': 'Экспорт или восстановление',
    },
    'resetDefaultsDone': {
      'tr': 'Planora varsayılan verilere döndürüldü.',
      'en': 'Planora has been reset to default data.',
      'ru': 'Planora сброшена к данным по умолчанию.',
    },
    'planoraUser': {
      'tr': 'Planora Kullanıcısı',
      'en': 'Planora User',
      'ru': 'Пользователь Planora',
    },
    'monthlyPlanActive': {
      'tr': 'Aylık plan aktif',
      'en': 'Monthly plan active',
      'ru': 'Месячный план активен',
    },
    'restartOnboarding': {
      'tr': 'İlk Kurulumu Tekrar Aç',
      'en': 'Open Initial Setup Again',
      'ru': 'Открыть начальную настройку снова',
    },
    'resetDefaults': {
      'tr': 'Varsayılan Verilere Dön',
      'en': 'Reset to Default Data',
      'ru': 'Вернуться к данным по умолчанию',
    },
    'clearAllData': {
      'tr': 'Tüm Verileri Temizle',
      'en': 'Clear All Data',
      'ru': 'Очистить все данные',
    },
    'clearAllDataDialogTitle': {
      'tr': 'Tüm veriler silinsin mi?',
      'en': 'Clear all data?',
      'ru': 'Очистить все данные?',
    },
    'clearAllDataDialogDescription': {
      'tr': 'Bu işlem ödemeleri, harcamaları, ek gelirleri, ödeme durumlarını ve kategori limitlerini temizler. İşlem geri alınamaz.',
      'en': 'This will clear payments, expenses, extra income, payment statuses, and category limits. This action cannot be undone.',
      'ru': 'Это удалит платежи, расходы, дополнительные доходы, статусы платежей и лимиты категорий. Действие нельзя отменить.',
    },
    'cancel': {
      'tr': 'İptal',
      'en': 'Cancel',
      'ru': 'Отмена',
    },
    'clearAllDataConfirm': {
      'tr': 'Tümünü Sil',
      'en': 'Clear All',
      'ru': 'Удалить всё',
    },
    'clearAllDataDone': {
      'tr': 'Tüm veriler temizlendi.',
      'en': 'All data has been cleared.',
      'ru': 'Все данные очищены.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _languageLabel(String code, String uiLanguage) {
  switch (code) {
    case 'en':
      return uiLanguage == 'ru' ? 'Английский' : 'English';
    case 'ru':
      return uiLanguage == 'en' ? 'Russian' : 'Русский';
    case 'tr':
    default:
      if (uiLanguage == 'en') return 'Turkish';
      if (uiLanguage == 'ru') return 'Турецкий';
      return 'Türkçe';
  }
}



class _AdvancedActionsSection extends StatelessWidget {
  const _AdvancedActionsSection({
    required this.title,
    required this.restartTitle,
    required this.clearTitle,
    required this.onRestart,
    required this.onClear,
  });

  final String title;
  final String restartTitle;
  final String clearTitle;
  final VoidCallback onRestart;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 12),
          _AdvancedActionButton(
            title: restartTitle,
            icon: Icons.flag_rounded,
            color: AppColors.brandBlue,
            onTap: onRestart,
          ),
          const SizedBox(height: 8),
          _AdvancedActionButton(
            title: clearTitle,
            icon: Icons.delete_forever_rounded,
            color: AppColors.danger,
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}

class _AdvancedActionButton extends StatelessWidget {
  const _AdvancedActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
          ),
        ),
        ...children.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: item,
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
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
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
