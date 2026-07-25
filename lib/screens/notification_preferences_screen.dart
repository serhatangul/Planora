import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

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
                        _notificationText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _notificationText(lang, 'subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _activeAlertTypeText(lang, controller.activeNotificationPreferenceCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _notificationText(lang, 'howItWorks')),
                const SizedBox(height: 12),
                _ExplanationCard(
                  icon: Icons.category_rounded,
                  title: _notificationText(lang, 'categoryLimitsInfoTitle'),
                  description: _notificationText(lang, 'categoryLimitsInfoDescription'),
                  color: AppColors.warning,
                ),
                _ExplanationCard(
                  icon: Icons.speed_rounded,
                  title: _notificationText(lang, 'dailySafeLimitInfoTitle'),
                  description: _notificationText(lang, 'dailySafeLimitInfoDescription'),
                  color: AppColors.brandGreen,
                ),
                _ExplanationCard(
                  icon: Icons.warning_rounded,
                  title: _notificationText(lang, 'latePaymentsInfoTitle'),
                  description: _notificationText(lang, 'latePaymentsInfoDescription'),
                  color: AppColors.danger,
                ),
                const SizedBox(height: 12),
                SectionHeader(title: _notificationText(lang, 'alertPreferences')),
                const SizedBox(height: 12),
                _PreferenceSwitch(
                  title: _notificationText(lang, 'upcomingPayments'),
                  subtitle: _notificationText(lang, 'upcomingPaymentsSubtitle'),
                  icon: Icons.schedule_rounded,
                  value: controller.notifyUpcomingPayments,
                  onChanged: (value) => controller.updateNotificationPreferences(
                    upcomingPayments: value,
                  ),
                ),
                _PreferenceSwitch(
                  title: _notificationText(lang, 'latePayments'),
                  subtitle: _notificationText(lang, 'latePaymentsSubtitle'),
                  icon: Icons.warning_rounded,
                  value: controller.notifyLatePayments,
                  danger: true,
                  onChanged: (value) => controller.updateNotificationPreferences(
                    latePayments: value,
                  ),
                ),
                _PreferenceSwitch(
                  title: _notificationText(lang, 'categoryLimits'),
                  subtitle: _notificationText(lang, 'categoryLimitsSubtitle'),
                  icon: Icons.category_rounded,
                  value: controller.notifyCategoryLimits,
                  onChanged: (value) => controller.updateNotificationPreferences(
                    categoryLimits: value,
                  ),
                ),
                _PreferenceSwitch(
                  title: _notificationText(lang, 'dailySafeLimit'),
                  subtitle: _notificationText(lang, 'dailySafeLimitSubtitle'),
                  icon: Icons.speed_rounded,
                  value: controller.notifyDailySafeLimit,
                  onChanged: (value) => controller.updateNotificationPreferences(
                    dailySafeLimit: value,
                  ),
                ),
                _PreferenceSwitch(
                  title: _notificationText(lang, 'salaryDay'),
                  subtitle: _notificationText(lang, 'salaryDaySubtitle'),
                  icon: Icons.event_available_rounded,
                  value: controller.notifySalaryDay,
                  onChanged: (value) => controller.updateNotificationPreferences(
                    salaryDay: value,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: controller.resetNotificationPreferences,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.stroke),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restart_alt_rounded, color: AppColors.textPrimary),
                              const SizedBox(width: 8),
                              Text(
                                _notificationText(lang, 'resetDefaults'),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _notificationText(lang, 'footerNote'),
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


String _notificationText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Bildirimler',
      'en': 'Notifications',
      'ru': 'Уведомления',
    },
    'subtitle': {
      'tr': 'Uygulama içi akıllı uyarılarda hangi konuları görmek istediğini seç.',
      'en': 'Choose which topics you want to see in in-app smart alerts.',
      'ru': 'Выберите, какие темы показывать во внутренних умных уведомлениях.',
    },
    'howItWorks': {
      'tr': 'Akıllı uyarılar nasıl çalışır?',
      'en': 'How smart alerts work',
      'ru': 'Как работают умные уведомления',
    },
    'alertPreferences': {
      'tr': 'Uyarı tercihleri',
      'en': 'Alert preferences',
      'ru': 'Настройки уведомлений',
    },
    'categoryLimitsInfoTitle': {
      'tr': 'Kategori limit uyarıları',
      'en': 'Category limit alerts',
      'ru': 'Уведомления о лимитах категорий',
    },
    'categoryLimitsInfoDescription': {
      'tr': 'Bir kategori limitinin %80’ine yaklaştığında veya limit aşıldığında uygulama içinde uyarı gösterir.',
      'en': 'Shows an in-app alert when a category reaches 80% of its limit or goes over the limit.',
      'ru': 'Показывает уведомление в приложении, когда категория достигает 80% лимита или превышает лимит.',
    },
    'dailySafeLimitInfoTitle': {
      'tr': 'Günlük güvenli limit',
      'en': 'Daily safe limit',
      'ru': 'Дневной безопасный лимит',
    },
    'dailySafeLimitInfoDescription': {
      'tr': 'Maaş gününe kadar kalan günlere göre önerilen günlük harcama limitini takip eder.',
      'en': 'Tracks the suggested daily spending limit based on the days left until salary day.',
      'ru': 'Отслеживает рекомендуемый дневной лимит расходов по дням до зарплаты.',
    },
    'latePaymentsInfoTitle': {
      'tr': 'Geciken ödemeler',
      'en': 'Late payments',
      'ru': 'Просроченные платежи',
    },
    'latePaymentsInfoDescription': {
      'tr': 'Ödeme tarihi geçen ve hâlâ bekleyen kayıtları uyarı olarak gösterir.',
      'en': 'Shows overdue records that are still waiting as alerts.',
      'ru': 'Показывает просроченные и ещё не оплаченные записи как уведомления.',
    },
    'upcomingPayments': {
      'tr': 'Yaklaşan ödemeler',
      'en': 'Upcoming payments',
      'ru': 'Предстоящие платежи',
    },
    'upcomingPaymentsSubtitle': {
      'tr': 'Ödeme günü yaklaşan kayıtlar için uyarı göster.',
      'en': 'Show alerts for records with an upcoming payment day.',
      'ru': 'Показывать уведомления для платежей с близкой датой.',
    },
    'latePayments': {
      'tr': 'Geciken ödemeler',
      'en': 'Late payments',
      'ru': 'Просроченные платежи',
    },
    'latePaymentsSubtitle': {
      'tr': 'Tarihi geçmiş ve bekleyen ödemeler için uyarı göster.',
      'en': 'Show alerts for overdue and waiting payments.',
      'ru': 'Показывать уведомления для просроченных и ожидающих платежей.',
    },
    'categoryLimits': {
      'tr': 'Kategori limitleri',
      'en': 'Category limits',
      'ru': 'Лимиты категорий',
    },
    'categoryLimitsSubtitle': {
      'tr': 'Limitin %80’ine yaklaşınca veya limit aşılınca Dashboard ve Analiz ekranında uyarı göster.',
      'en': 'Show alerts on Dashboard and Analysis when a category reaches 80% of its limit or exceeds it.',
      'ru': 'Показывать уведомления на Главной и в Анализе, когда категория достигает 80% лимита или превышает его.',
    },
    'dailySafeLimit': {
      'tr': 'Günlük güvenli limit',
      'en': 'Daily safe limit',
      'ru': 'Дневной безопасный лимит',
    },
    'dailySafeLimitSubtitle': {
      'tr': 'Günlük güvenli harcama limiti düştüğünde uyarı göster.',
      'en': 'Show alerts when the daily safe spending limit drops.',
      'ru': 'Показывать уведомления, когда дневной безопасный лимит снижается.',
    },
    'salaryDay': {
      'tr': 'Maaş günü',
      'en': 'Salary day',
      'ru': 'День зарплаты',
    },
    'salaryDaySubtitle': {
      'tr': 'Bir sonraki maaş günü yaklaştığında uyarı göster.',
      'en': 'Show alerts when the next salary day is approaching.',
      'ru': 'Показывать уведомления, когда приближается день зарплаты.',
    },
    'resetDefaults': {
      'tr': 'Varsayılana Döndür',
      'en': 'Reset to Defaults',
      'ru': 'Сбросить по умолчанию',
    },
    'footerNote': {
      'tr': 'Bu tercihler uygulama içindeki akıllı uyarıları yönetir. iOS sistem bildirimi kullanılmadan, uyarılar Planora içinde gösterilir.',
      'en': 'These preferences manage in-app smart alerts. Alerts are shown inside Planora without using iOS system notifications.',
      'ru': 'Эти настройки управляют умными уведомлениями внутри приложения. Уведомления показываются в Planora без системных уведомлений iOS.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _activeAlertTypeText(String code, int count) {
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


class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
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
        color: Colors.white,
        borderColor: color.withOpacity(0.18),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(17),
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

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.danger = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.brandGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                  const SizedBox(height: 3),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeColor: AppColors.brandGreen,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
