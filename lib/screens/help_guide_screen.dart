import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class HelpGuideScreen extends StatelessWidget {
  const HelpGuideScreen({super.key});

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
                    _helpText(lang, 'title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _helpText(lang, 'subtitle'),
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
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _helpText(lang, 'heroText'),
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
            SectionHeader(title: _helpText(lang, 'startOrder')),
            const SizedBox(height: 12),
            _GuideStep(
              number: '1',
              title: _helpText(lang, 'step1Title'),
              description: _helpText(lang, 'step1Description'),
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.brandGreen,
            ),
            _GuideStep(
              number: '2',
              title: _helpText(lang, 'step2Title'),
              description: _helpText(lang, 'step2Description'),
              icon: Icons.receipt_long_rounded,
              color: AppColors.brandBlue,
            ),
            _GuideStep(
              number: '3',
              title: _helpText(lang, 'step3Title'),
              description: _helpText(lang, 'step3Description'),
              icon: Icons.add_chart_rounded,
              color: AppColors.warning,
            ),
            _GuideStep(
              number: '4',
              title: _helpText(lang, 'step4Title'),
              description: _helpText(lang, 'step4Description'),
              icon: Icons.pie_chart_rounded,
              color: AppColors.danger,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _helpText(lang, 'screensPurpose')),
            const SizedBox(height: 12),
            _FeatureCard(
              title: _helpText(lang, 'homeTitle'),
              description: _helpText(lang, 'homeDescription'),
              icon: Icons.home_rounded,
            ),
            _FeatureCard(
              title: _helpText(lang, 'paymentsTitle'),
              description: _helpText(lang, 'paymentsDescription'),
              icon: Icons.credit_card_rounded,
            ),
            _FeatureCard(
              title: _helpText(lang, 'calendarTitle'),
              description: _helpText(lang, 'calendarDescription'),
              icon: Icons.calendar_month_rounded,
            ),
            _FeatureCard(
              title: _helpText(lang, 'analysisTitle'),
              description: _helpText(lang, 'analysisDescription'),
              icon: Icons.donut_large_rounded,
            ),
            _FeatureCard(
              title: _helpText(lang, 'profileTitle'),
              description: _helpText(lang, 'profileDescription'),
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _helpText(lang, 'tips')),
            const SizedBox(height: 12),
            _TipCard(
              title: _helpText(lang, 'oneTimeTipTitle'),
              description: _helpText(lang, 'oneTimeTipDescription'),
              icon: Icons.event_note_rounded,
            ),
            _TipCard(
              title: _helpText(lang, 'monthlyPaymentTipTitle'),
              description: _helpText(lang, 'monthlyPaymentTipDescription'),
              icon: Icons.repeat_rounded,
            ),
            _TipCard(
              title: _helpText(lang, 'privacyTipTitle'),
              description: _helpText(lang, 'privacyTipDescription'),
              icon: Icons.visibility_off_rounded,
            ),
            _TipCard(
              title: _helpText(lang, 'backupTipTitle'),
              description: _helpText(lang, 'backupTipDescription'),
              icon: Icons.backup_rounded,
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
                      _helpText(lang, 'dataNote'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


String _helpText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {'tr': 'Kullanım rehberi', 'en': 'User guide', 'ru': 'Руководство'},
    'subtitle': {'tr': 'Planora’yı daha verimli kullanmak için temel akış ve ekran açıklamaları.', 'en': 'Basic flow and screen explanations to use Planora more efficiently.', 'ru': 'Основной порядок работы и описание экранов для более удобного использования Planora.'},
    'heroText': {'tr': 'Önce gelirini belirle, sonra aylık ödemelerini gir, ardından harcama ve ek gelirleri ay boyunca takip et.', 'en': 'First set your income, then add monthly payments, then track expenses and extra income during the month.', 'ru': 'Сначала укажите доход, затем добавьте ежемесячные платежи, после этого отслеживайте расходы и доп. доходы в течение месяца.'},
    'startOrder': {'tr': 'Başlangıç sırası', 'en': 'Getting started', 'ru': 'Порядок начала'},
    'screensPurpose': {'tr': 'Ekranlar ne işe yarar?', 'en': 'What are the screens for?', 'ru': 'Для чего нужны экраны?'},
    'tips': {'tr': 'İpuçları', 'en': 'Tips', 'ru': 'Советы'},

    'step1Title': {'tr': 'Aylık geliri ayarla', 'en': 'Set monthly income', 'ru': 'Укажите месячный доход'},
    'step1Description': {'tr': 'Profil > Aylık gelir bölümünden sabit aylık gelirini ve maaş gününü gir.', 'en': 'Enter your fixed monthly income and salary day from Profile > Monthly income.', 'ru': 'Введите стабильный месячный доход и день зарплаты в Профиль > Месячный доход.'},
    'step2Title': {'tr': 'Aylık ödemeleri ekle', 'en': 'Add monthly payments', 'ru': 'Добавьте ежемесячные платежи'},
    'step2Description': {'tr': 'Ödeme ekranından kira, kredi, taksit, fatura gibi düzenli veya tek seferlik ödemeleri ekle.', 'en': 'Add regular or one-time payments such as rent, loans, installments, and bills from the Payments screen.', 'ru': 'Добавьте регулярные или разовые платежи, например аренду, кредит, рассрочку и счета, на экране платежей.'},
    'step3Title': {'tr': 'Harcama ve ek gelirleri takip et', 'en': 'Track expenses and extra income', 'ru': 'Отслеживайте расходы и доп. доходы'},
    'step3Description': {'tr': 'Ay içinde yaptığın değişken harcamaları ve prim/iade/freelance gibi ek gelirleri gir.', 'en': 'Enter variable expenses and extra income such as bonuses, refunds, or freelance earnings during the month.', 'ru': 'Вносите переменные расходы и доп. доходы, например премии, возвраты или фриланс, в течение месяца.'},
    'step4Title': {'tr': 'Analiz ve limitleri kontrol et', 'en': 'Check analysis and limits', 'ru': 'Проверяйте анализ и лимиты'},
    'step4Description': {'tr': 'Analiz ekranından kategori limitlerini, bütçe sağlığını ve ay sonu tahminini takip et.', 'en': 'Track category limits, budget health, and end-of-month forecast from the Analysis screen.', 'ru': 'Следите за лимитами категорий, состоянием бюджета и прогнозом на конец месяца на экране анализа.'},

    'homeTitle': {'tr': 'Ana ekran', 'en': 'Home', 'ru': 'Главная'},
    'homeDescription': {'tr': 'Bu ayki gelir, ödeme, serbest bakiye, günlük güvenli limit ve hızlı özetleri gösterir.', 'en': 'Shows this month’s income, payments, free balance, daily safe limit, and quick summaries.', 'ru': 'Показывает доход за месяц, платежи, свободный баланс, дневной безопасный лимит и краткие сводки.'},
    'paymentsTitle': {'tr': 'Ödeme', 'en': 'Payments', 'ru': 'Платежи'},
    'paymentsDescription': {'tr': 'Aylık veya tek seferlik ödemeleri eklemek, düzenlemek ve ödendi/bekliyor yapmak için kullanılır.', 'en': 'Used to add, edit, and mark monthly or one-time payments as paid/waiting.', 'ru': 'Используется для добавления, редактирования и отметки ежемесячных или разовых платежей как оплачено/ожидает.'},
    'calendarTitle': {'tr': 'Takvim', 'en': 'Calendar', 'ru': 'Календарь'},
    'calendarDescription': {'tr': 'Ödeme, harcama ve ek gelirleri gün bazında görmeni sağlar.', 'en': 'Lets you view payments, expenses, and extra income by day.', 'ru': 'Позволяет просматривать платежи, расходы и доп. доходы по дням.'},
    'analysisTitle': {'tr': 'Analiz', 'en': 'Analysis', 'ru': 'Анализ'},
    'analysisDescription': {'tr': 'Kategori limitleri, bütçe sağlığı, ay sonu tahmini ve detaylı raporları gösterir.', 'en': 'Shows category limits, budget health, end-of-month forecast, and detailed reports.', 'ru': 'Показывает лимиты категорий, состояние бюджета, прогноз на конец месяца и подробные отчёты.'},
    'profileTitle': {'tr': 'Profil', 'en': 'Profile', 'ru': 'Профиль'},
    'profileDescription': {'tr': 'Gelir, para birimi, gizlilik, bildirim tercihleri, yedekleme ve veri yönetimi ayarlarını içerir.', 'en': 'Includes income, currency, privacy, notification preferences, backup, and data management settings.', 'ru': 'Содержит настройки дохода, валюты, приватности, уведомлений, резервного копирования и управления данными.'},

    'oneTimeTipTitle': {'tr': 'Tek seferlik ödeme ne zaman kullanılır?', 'en': 'When to use a one-time payment?', 'ru': 'Когда использовать разовый платёж?'},
    'oneTimeTipDescription': {'tr': 'Sadece seçili ayda görünecek geçici ödemeler için kullan. Örneğin cihaz tamiri, ekstra borç veya tek aylık taksit.', 'en': 'Use it for temporary payments that should appear only in the selected month, such as device repair, extra debt, or a one-month installment.', 'ru': 'Используйте для временных платежей, которые должны отображаться только в выбранном месяце, например ремонт устройства, дополнительный долг или разовая рассрочка.'},
    'monthlyPaymentTipTitle': {'tr': 'Aylık ödeme ne zaman kullanılır?', 'en': 'When to use a monthly payment?', 'ru': 'Когда использовать ежемесячный платёж?'},
    'monthlyPaymentTipDescription': {'tr': 'Her ay tekrar eden kira, internet, kredi, abonelik gibi ödemeler için kullan.', 'en': 'Use it for recurring payments such as rent, internet, loans, and subscriptions.', 'ru': 'Используйте для повторяющихся платежей, например аренды, интернета, кредита и подписок.'},
    'privacyTipTitle': {'tr': 'Gizli tutar modu', 'en': 'Hidden amount mode', 'ru': 'Режим скрытых сумм'},
    'privacyTipDescription': {'tr': 'Telefonu başkasının yanında açarken tutarları gizlemek için Profil > Gizlilik bölümünden aktif et.', 'en': 'Enable it from Profile > Privacy to hide amounts when opening the app around others.', 'ru': 'Включите в Профиль > Приватность, чтобы скрывать суммы, когда открываете приложение рядом с другими.'},
    'backupTipTitle': {'tr': 'Yedek almayı unutma', 'en': 'Do not forget to back up', 'ru': 'Не забывайте делать резервную копию'},
    'backupTipDescription': {'tr': 'Büyük temizlik veya veri geri yükleme işlemlerinden önce Profil > Verileri yedekle bölümünden yedek oluştur.', 'en': 'Create a backup from Profile > Backup data before major cleanup or data restore actions.', 'ru': 'Создайте резервную копию в Профиль > Резервное копирование перед большой очисткой или восстановлением данных.'},
    'dataNote': {'tr': 'Planora’daki veriler cihaz üzerinde saklanır. Uygulamayı silmeden önce yedek almak önemlidir.', 'en': 'Planora data is stored on the device. It is important to create a backup before deleting the app.', 'ru': 'Данные Planora хранятся на устройстве. Перед удалением приложения важно создать резервную копию.'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: color, size: 21),
                  Positioned(
                    right: 6,
                    top: 5,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.brandBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
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

class _TipCard extends StatelessWidget {
  const _TipCard({
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
