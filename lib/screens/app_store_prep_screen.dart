import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class AppStorePrepScreen extends StatelessWidget {
  const AppStorePrepScreen({super.key});

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
                    _appStorePrepText(lang, 'title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _appStorePrepText(lang, 'subtitle'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PremiumCard(
              color: AppColors.darkCard,
              borderColor: AppColors.darkCard,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppGradients.brand,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _appStorePrepText(lang, 'hero'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _appStorePrepText(lang, 'appInfo')),
            const SizedBox(height: 12),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'appNameTitle'),
              description: _appStorePrepText(lang, 'appNameDescription'),
              icon: Icons.drive_file_rename_outline_rounded,
              status: _PrepStatus.ready,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'shortDescriptionTitle'),
              description: _appStorePrepText(lang, 'shortDescriptionDescription'),
              icon: Icons.short_text_rounded,
              status: _PrepStatus.needsReview,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'storeDescriptionTitle'),
              description: _appStorePrepText(lang, 'storeDescriptionDescription'),
              icon: Icons.description_rounded,
              status: _PrepStatus.needsReview,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'keywordsTitle'),
              description: _appStorePrepText(lang, 'keywordsDescription'),
              icon: Icons.key_rounded,
              status: _PrepStatus.needsReview,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _appStorePrepText(lang, 'technicalCheck')),
            const SizedBox(height: 12),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'dataPersistenceTitle'),
              description: _appStorePrepText(lang, 'dataPersistenceDescription'),
              icon: Icons.save_rounded,
              status: _PrepStatus.ready,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'backupRestoreTitle'),
              description: _appStorePrepText(lang, 'backupRestoreDescription'),
              icon: Icons.backup_rounded,
              status: _PrepStatus.ready,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'emptyStatesTitle'),
              description: _appStorePrepText(lang, 'emptyStatesDescription'),
              icon: Icons.inbox_rounded,
              status: _PrepStatus.ready,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'darkModeTitle'),
              description: _appStorePrepText(lang, 'darkModeDescription'),
              icon: Icons.dark_mode_rounded,
              status: _PrepStatus.later,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _appStorePrepText(lang, 'privacySupport')),
            const SizedBox(height: 12),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'dataSafetyScreenTitle'),
              description: _appStorePrepText(lang, 'dataSafetyScreenDescription'),
              icon: Icons.security_rounded,
              status: _PrepStatus.ready,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'privacyPolicyTitle'),
              description: _appStorePrepText(lang, 'privacyPolicyDescription'),
              icon: Icons.privacy_tip_rounded,
              status: _PrepStatus.needsReview,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'supportContactTitle'),
              description: _appStorePrepText(lang, 'supportContactDescription'),
              icon: Icons.support_agent_rounded,
              status: _PrepStatus.needsReview,
            ),
            const SizedBox(height: 24),
            SectionHeader(title: _appStorePrepText(lang, 'testflightCheck')),
            const SizedBox(height: 12),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'basicFlowTitle'),
              description: _appStorePrepText(lang, 'basicFlowDescription'),
              icon: Icons.fact_check_rounded,
              status: _PrepStatus.needsReview,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'monthTestsTitle'),
              description: _appStorePrepText(lang, 'monthTestsDescription'),
              icon: Icons.calendar_month_rounded,
              status: _PrepStatus.needsReview,
            ),
            _PrepItem(
              lang: lang,
              title: _appStorePrepText(lang, 'realDeviceTitle'),
              description: _appStorePrepText(lang, 'realDeviceDescription'),
              icon: Icons.phone_iphone_rounded,
              status: _PrepStatus.needsReview,
            ),
          ],
        ),
      ),
    );
  }
}


String _appStorePrepText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {'tr': 'App Store hazırlığı', 'en': 'App Store preparation', 'ru': 'Подготовка к App Store'},
    'subtitle': {'tr': 'TestFlight ve App Store yayını öncesi kontrol edilmesi gereken temel başlıklar.', 'en': 'Key items to check before TestFlight and App Store release.', 'ru': 'Основные пункты проверки перед TestFlight и публикацией в App Store.'},
    'hero': {'tr': 'Planora yayın öncesi kalite kontrol listesi', 'en': 'Planora pre-release quality checklist', 'ru': 'Чек-лист качества Planora перед публикацией'},
    'appInfo': {'tr': 'Uygulama bilgileri', 'en': 'App information', 'ru': 'Информация о приложении'},
    'technicalCheck': {'tr': 'Teknik kontrol', 'en': 'Technical check', 'ru': 'Техническая проверка'},
    'privacySupport': {'tr': 'Gizlilik ve destek', 'en': 'Privacy and support', 'ru': 'Приватность и поддержка'},
    'testflightCheck': {'tr': 'TestFlight kontrolü', 'en': 'TestFlight check', 'ru': 'Проверка TestFlight'},

    'appNameTitle': {'tr': 'Uygulama adı', 'en': 'App name', 'ru': 'Название приложения'},
    'appNameDescription': {'tr': 'App Store tarafında kullanılacak isim netleştirilmeli: Planora.', 'en': 'The name to be used on the App Store should be finalized: Planora.', 'ru': 'Нужно зафиксировать название для App Store: Planora.'},
    'shortDescriptionTitle': {'tr': 'Kısa açıklama', 'en': 'Short description', 'ru': 'Краткое описание'},
    'shortDescriptionDescription': {'tr': 'Kişisel bütçe, ödeme ve harcama takibi için kısa, net açıklama hazırlanmalı.', 'en': 'A short and clear description for personal budget, payment, and expense tracking should be prepared.', 'ru': 'Нужно подготовить короткое и понятное описание для учёта бюджета, платежей и расходов.'},
    'storeDescriptionTitle': {'tr': 'App Store açıklaması', 'en': 'App Store description', 'ru': 'Описание в App Store'},
    'storeDescriptionDescription': {'tr': 'Ana özellikleri, veri güvenliği yaklaşımını ve kullanıcı faydasını anlatan açıklama hazırlanmalı.', 'en': 'Prepare a description covering key features, the data safety approach, and user benefits.', 'ru': 'Нужно подготовить описание основных функций, подхода к безопасности данных и пользы для пользователя.'},
    'keywordsTitle': {'tr': 'Anahtar kelimeler', 'en': 'Keywords', 'ru': 'Ключевые слова'},
    'keywordsDescription': {'tr': 'budget, finance, planner, payment, expense gibi arama kelimeleri belirlenecek.', 'en': 'Search keywords such as budget, finance, planner, payment, and expense should be defined.', 'ru': 'Нужно определить поисковые слова, например budget, finance, planner, payment, expense.'},

    'dataPersistenceTitle': {'tr': 'Veri kaydı', 'en': 'Data persistence', 'ru': 'Сохранение данных'},
    'dataPersistenceDescription': {'tr': 'Gelir, ödeme, harcama, ek gelir, kategori ve ayarlar uygulama kapanıp açılınca korunmalı.', 'en': 'Income, payments, expenses, extra income, categories, and settings should remain after closing and reopening the app.', 'ru': 'Доход, платежи, расходы, доп. доходы, категории и настройки должны сохраняться после закрытия и повторного открытия приложения.'},
    'backupRestoreTitle': {'tr': 'Backup / restore', 'en': 'Backup / restore', 'ru': 'Резервная копия / восстановление'},
    'backupRestoreDescription': {'tr': 'Yedek dışa aktarma ve geri yükleme test edilmeli.', 'en': 'Backup export and restore should be tested.', 'ru': 'Нужно протестировать экспорт резервной копии и восстановление.'},
    'emptyStatesTitle': {'tr': 'Boş veri ekranları', 'en': 'Empty data screens', 'ru': 'Экраны без данных'},
    'emptyStatesDescription': {'tr': 'Yeni kullanıcıda boş ekranlar hata gibi değil, yönlendirici görünmeli.', 'en': 'For new users, empty screens should look helpful rather than like an error.', 'ru': 'Для нового пользователя пустые экраны должны выглядеть как подсказки, а не как ошибка.'},
    'darkModeTitle': {'tr': 'Koyu mod', 'en': 'Dark mode', 'ru': 'Тёмный режим'},
    'darkModeDescription': {'tr': 'Tema tercihi altyapısı var; tam koyu UI daha sonra kontrollü yapılacak.', 'en': 'Theme preference infrastructure exists; full dark UI will be handled carefully later.', 'ru': 'Инфраструктура выбора темы есть; полноценный тёмный UI будет сделан позже контролируемо.'},

    'dataSafetyScreenTitle': {'tr': 'Veri güvenliği ekranı', 'en': 'Data safety screen', 'ru': 'Экран безопасности данных'},
    'dataSafetyScreenDescription': {'tr': 'Profil > Hakkında ekranında veri güvenliği bilgileri eklendi.', 'en': 'Data safety information has been added to Profile > About.', 'ru': 'Информация о безопасности данных добавлена в Профиль > О приложении.'},
    'privacyPolicyTitle': {'tr': 'Gizlilik politikası', 'en': 'Privacy policy', 'ru': 'Политика конфиденциальности'},
    'privacyPolicyDescription': {'tr': 'App Store için web üzerinde erişilebilir gizlilik politikası sayfası hazırlanmalı.', 'en': 'A web-accessible privacy policy page should be prepared for the App Store.', 'ru': 'Для App Store нужно подготовить страницу политики конфиденциальности, доступную в интернете.'},
    'supportContactTitle': {'tr': 'Destek iletişimi', 'en': 'Support contact', 'ru': 'Контакт поддержки'},
    'supportContactDescription': {'tr': 'Kullanıcıların ulaşabileceği destek e-posta adresi belirlenmeli.', 'en': 'A support email address that users can contact should be defined.', 'ru': 'Нужно указать e-mail поддержки, по которому смогут обращаться пользователи.'},

    'basicFlowTitle': {'tr': 'Temel akış testi', 'en': 'Basic flow test', 'ru': 'Тест основного сценария'},
    'basicFlowDescription': {'tr': 'Gelir ayarla, ödeme ekle, harcama ekle, ek gelir ekle, ay değiştir, yedek al/geri yükle.', 'en': 'Set income, add payment, add expense, add extra income, change month, back up and restore.', 'ru': 'Указать доход, добавить платёж, расход, доп. доход, сменить месяц, сделать резервную копию и восстановить.'},
    'monthTestsTitle': {'tr': 'Farklı ay testleri', 'en': 'Different month tests', 'ru': 'Тесты разных месяцев'},
    'monthTestsDescription': {'tr': 'Aylık ödeme, tek seferlik ödeme ve maaş günü döngüsü farklı aylarda kontrol edilmeli.', 'en': 'Monthly payments, one-time payments, and salary day cycle should be checked across different months.', 'ru': 'Ежемесячные платежи, разовые платежи и цикл зарплатного дня нужно проверить в разных месяцах.'},
    'realDeviceTitle': {'tr': 'Gerçek cihaz testi', 'en': 'Real device test', 'ru': 'Тест на реальном устройстве'},
    'realDeviceDescription': {'tr': 'Simulator sonrası gerçek iPhone üzerinde performans ve veri kaydı test edilmeli.', 'en': 'After the Simulator, performance and data persistence should be tested on a real iPhone.', 'ru': 'После Simulator нужно проверить производительность и сохранение данных на реальном iPhone.'},

    'statusReady': {'tr': 'Hazır', 'en': 'Ready', 'ru': 'Готово'},
    'statusReview': {'tr': 'Kontrol', 'en': 'Review', 'ru': 'Проверить'},
    'statusLater': {'tr': 'Sonra', 'en': 'Later', 'ru': 'Позже'},
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

enum _PrepStatus {
  ready,
  needsReview,
  later,
}

class _PrepItem extends StatelessWidget {
  const _PrepItem({
    required this.lang,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  final String lang;
  final String title;
  final String description;
  final IconData icon;
  final _PrepStatus status;

  Color get _color {
    switch (status) {
      case _PrepStatus.ready:
        return AppColors.brandGreen;
      case _PrepStatus.needsReview:
        return AppColors.warning;
      case _PrepStatus.later:
        return AppColors.brandBlue;
    }
  }

  String _label(String lang) {
    switch (status) {
      case _PrepStatus.ready:
        return _appStorePrepText(lang, 'statusReady');
      case _PrepStatus.needsReview:
        return _appStorePrepText(lang, 'statusReview');
      case _PrepStatus.later:
        return _appStorePrepText(lang, 'statusLater');
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case _PrepStatus.ready:
        return Icons.check_circle_rounded;
      case _PrepStatus.needsReview:
        return Icons.pending_rounded;
      case _PrepStatus.later:
        return Icons.schedule_rounded;
    }
  }

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
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: _color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, color: _color, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _label(lang),
                              style: TextStyle(
                                color: _color,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
