import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class AboutDataSafetyScreen extends StatelessWidget {
  const AboutDataSafetyScreen({super.key});

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
                    _aboutText(lang, 'title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _aboutText(lang, 'subtitle'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PremiumCard(
              color: AppColors.darkCard,
              borderColor: AppColors.darkCard,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Planora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _aboutText(lang, 'appDescription'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _aboutText(lang, 'heroMessage'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(title: _aboutText(lang, 'trustTitle')),
            const SizedBox(height: 12),
            _SafetyCard(
              title: _aboutText(lang, 'localDataTitle'),
              description: _aboutText(lang, 'localDataDescription'),
              icon: Icons.phone_iphone_rounded,
            ),
            _SafetyCard(
              title: _aboutText(lang, 'noSaleTitle'),
              description: _aboutText(lang, 'noSaleDescription'),
              icon: Icons.lock_person_rounded,
            ),
            _SafetyCard(
              title: _aboutText(lang, 'noBankTitle'),
              description: _aboutText(lang, 'noBankDescription'),
              icon: Icons.account_balance_rounded,
            ),
            _SafetyCard(
              title: _aboutText(lang, 'manualControlTitle'),
              description: _aboutText(lang, 'manualControlDescription'),
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 22),
            SectionHeader(title: _aboutText(lang, 'whatPlanoraDoes')),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.account_balance_wallet_rounded,
              title: _aboutText(lang, 'budgetTrackingTitle'),
              description: _aboutText(lang, 'budgetTrackingDescription'),
              color: AppColors.brandGreen,
            ),
            _InfoCard(
              icon: Icons.receipt_long_rounded,
              title: _aboutText(lang, 'paymentPlanTitle'),
              description: _aboutText(lang, 'paymentPlanDescription'),
              color: AppColors.brandBlue,
            ),
            _InfoCard(
              icon: Icons.pie_chart_rounded,
              title: _aboutText(lang, 'analysisLimitsTitle'),
              description: _aboutText(lang, 'analysisLimitsDescription'),
              color: AppColors.warning,
            ),
            const SizedBox(height: 22),
            SectionHeader(title: _aboutText(lang, 'privacyTools')),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.visibility_off_rounded,
              title: _aboutText(lang, 'privacyModeTitle'),
              description: _aboutText(lang, 'privacyModeDescription'),
              color: AppColors.brandBlue,
            ),
            _InfoCard(
              icon: Icons.backup_rounded,
              title: _aboutText(lang, 'backupControlTitle'),
              description: _aboutText(lang, 'backupControlDescription'),
              color: AppColors.brandGreen,
            ),
            const SizedBox(height: 22),
            SectionHeader(title: _aboutText(lang, 'importantNote')),
            const SizedBox(height: 12),
            PremiumCard(
              color: const Color(0xFFFFFBF4),
              borderColor: AppColors.warning.withOpacity(0.24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _aboutText(lang, 'disclaimer'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(title: _aboutText(lang, 'versionInfo')),
            const SizedBox(height: 12),
            _VersionRow(label: _aboutText(lang, 'application'), value: 'Planora'),
            _VersionRow(label: _aboutText(lang, 'appType'), value: _aboutText(lang, 'appTypeValue')),
            _VersionRow(label: _aboutText(lang, 'dataStorage'), value: _aboutText(lang, 'dataStorageValue')),
          ],
        ),
      ),
    );
  }
}

String _aboutText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Hakkında ve veri güvenliği',
      'en': 'About and data safety',
      'ru': 'О приложении и данных',
    },
    'subtitle': {
      'tr': 'Planora’nın ne yaptığı ve verilerin nasıl korunduğu.',
      'en': 'What Planora does and how your data is protected.',
      'ru': 'Что делает Planora и как защищаются ваши данные.',
    },
    'appDescription': {
      'tr': 'Kişisel bütçe planlayıcı',
      'en': 'Personal budget planner',
      'ru': 'Личный планировщик бюджета',
    },
    'heroMessage': {
      'tr': 'Planora, banka bağlantısı gerektirmeden bütçeni manuel ve güvenli şekilde takip etmen için tasarlandı.',
      'en': 'Planora is designed to help you track your budget manually and safely without requiring a bank connection.',
      'ru': 'Planora помогает вручную и безопасно отслеживать бюджет без подключения к банку.',
    },
    'trustTitle': {
      'tr': 'Güven ve veri yaklaşımı',
      'en': 'Trust and data approach',
      'ru': 'Подход к данным и доверию',
    },
    'localDataTitle': {
      'tr': 'Veriler cihazında kalır',
      'en': 'Your data stays on your device',
      'ru': 'Данные остаются на устройстве',
    },
    'localDataDescription': {
      'tr': 'Planora’da girdiğin bütçe bilgileri cihazın yerel depolama alanında tutulur.',
      'en': 'Budget information entered in Planora is stored locally on your device.',
      'ru': 'Бюджетные данные, введённые в Planora, хранятся локально на устройстве.',
    },
    'noSaleTitle': {
      'tr': 'Kişisel veriler satılmaz',
      'en': 'Personal data is not sold',
      'ru': 'Персональные данные не продаются',
    },
    'noSaleDescription': {
      'tr': 'Planora, kullanıcı verilerini satmak veya reklam verenlerle paylaşmak için tasarlanmamıştır.',
      'en': 'Planora is not designed to sell user data or share it with advertisers.',
      'ru': 'Planora не предназначена для продажи данных пользователей или передачи их рекламодателям.',
    },
    'noBankTitle': {
      'tr': 'Banka bağlantısı gerekmez',
      'en': 'No bank connection required',
      'ru': 'Подключение к банку не требуется',
    },
    'noBankDescription': {
      'tr': 'Bütçeni takip etmek için banka hesabı, kart veya finansal kurum bağlantısı eklemen gerekmez.',
      'en': 'You do not need to connect a bank account, card, or financial institution to track your budget.',
      'ru': 'Для отслеживания бюджета не нужно подключать банковский счёт, карту или финансовое учреждение.',
    },
    'manualControlTitle': {
      'tr': 'Kontrol kullanıcıdadır',
      'en': 'You stay in control',
      'ru': 'Контроль остаётся у пользователя',
    },
    'manualControlDescription': {
      'tr': 'Gelir, ödeme ve harcama kayıtlarını manuel olarak sen yönetirsin.',
      'en': 'You manually control your income, payments, and expense records.',
      'ru': 'Вы вручную управляете доходами, платежами и расходами.',
    },
    'whatPlanoraDoes': {
      'tr': 'Planora ne yapar?',
      'en': 'What does Planora do?',
      'ru': 'Что делает Planora?',
    },
    'budgetTrackingTitle': {
      'tr': 'Bütçe takibi',
      'en': 'Budget tracking',
      'ru': 'Учёт бюджета',
    },
    'budgetTrackingDescription': {
      'tr': 'Aylık gelir, ek gelir, harcama ve serbest bakiyeni tek ekranda takip etmene yardımcı olur.',
      'en': 'Helps you track monthly income, extra income, expenses, and free balance in one place.',
      'ru': 'Помогает отслеживать месячный доход, доп. доходы, расходы и свободный баланс в одном месте.',
    },
    'paymentPlanTitle': {
      'tr': 'Ödeme planı',
      'en': 'Payment plan',
      'ru': 'План платежей',
    },
    'paymentPlanDescription': {
      'tr': 'Sabit ödemelerini, ödeme durumlarını ve yaklaşan tarihleri ay bazında kontrol edebilirsin.',
      'en': 'You can manage fixed payments, payment status, and upcoming dates by month.',
      'ru': 'Можно управлять регулярными платежами, статусами и предстоящими датами по месяцам.',
    },
    'analysisLimitsTitle': {
      'tr': 'Analiz ve limitler',
      'en': 'Analysis and limits',
      'ru': 'Анализ и лимиты',
    },
    'analysisLimitsDescription': {
      'tr': 'Kategori dağılımı, bütçe sağlığı ve limit uyarıları ile finans durumunu daha net görürsün.',
      'en': 'Category distribution, budget health, and limit alerts help you understand your finances more clearly.',
      'ru': 'Распределение по категориям, состояние бюджета и лимиты помогают лучше понимать финансы.',
    },
    'privacyTools': {
      'tr': 'Gizlilik araçları',
      'en': 'Privacy tools',
      'ru': 'Инструменты приватности',
    },
    'backupControlTitle': {
      'tr': 'Yedekleme kullanıcı kontrolündedir',
      'en': 'Backup is under user control',
      'ru': 'Резервное копирование под контролем пользователя',
    },
    'backupControlDescription': {
      'tr': 'Yedek alma ve geri yükleme işlemlerini Profil bölümünden sen yönetirsin.',
      'en': 'You manage backup and restore actions from the Profile section.',
      'ru': 'Резервное копирование и восстановление управляются в разделе Профиль.',
    },
    'privacyModeTitle': {
      'tr': 'Tutarları gizleme',
      'en': 'Hide amounts',
      'ru': 'Скрытие сумм',
    },
    'privacyModeDescription': {
      'tr': 'Gizlilik moduyla ekrandaki finansal tutarları hızlıca gizleyebilirsin.',
      'en': 'Privacy mode lets you quickly hide financial amounts on screen.',
      'ru': 'Режим приватности позволяет быстро скрывать суммы на экране.',
    },
    'importantNote': {
      'tr': 'Önemli not',
      'en': 'Important note',
      'ru': 'Важное примечание',
    },
    'disclaimer': {
      'tr': 'Planora finansal danışmanlık hizmeti vermez. Uygulama, kişisel bütçe planlamanı takip etmen için hazırlanmış yardımcı bir araçtır.',
      'en': 'Planora does not provide financial advisory services. The app is a helper tool for tracking your personal budget planning.',
      'ru': 'Planora не предоставляет финансовые консультации. Приложение является вспомогательным инструментом для отслеживания личного бюджета.',
    },
    'versionInfo': {
      'tr': 'Uygulama bilgisi',
      'en': 'App information',
      'ru': 'Информация о приложении',
    },
    'application': {
      'tr': 'Uygulama',
      'en': 'Application',
      'ru': 'Приложение',
    },
    'appType': {
      'tr': 'Tür',
      'en': 'Type',
      'ru': 'Тип',
    },
    'appTypeValue': {
      'tr': 'Kişisel bütçe planlayıcı',
      'en': 'Personal budget planner',
      'ru': 'Личный планировщик бюджета',
    },
    'dataStorage': {
      'tr': 'Veri saklama',
      'en': 'Data storage',
      'ru': 'Хранение данных',
    },
    'dataStorageValue': {
      'tr': 'Yerel cihaz',
      'en': 'Local device',
      'ru': 'Локальное устройство',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        color: const Color(0xFFF4FFFB),
        borderColor: AppColors.brandGreen.withOpacity(0.20),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.brandGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
