import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class LanguagePreferenceScreen extends StatelessWidget {
  const LanguagePreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    final lang = controller.appLanguageCode;

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final currentLang = controller.appLanguageCode;

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
                        _text(currentLang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _text(currentLang, 'subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _text(currentLang, 'preferenceTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _languageSubtitle(currentLang),
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
                ),
                const SizedBox(height: 18),
                _LanguageOption(
                  title: _text(currentLang, 'turkish'),
                  subtitle: _text(currentLang, 'turkishSubtitle'),
                  flag: '🇹🇷',
                  code: 'tr',
                  selectedCode: controller.appLanguageCode,
                  onTap: () => controller.updateLanguagePreference('tr'),
                ),
                _LanguageOption(
                  title: _text(currentLang, 'english'),
                  subtitle: _text(currentLang, 'englishSubtitle'),
                  flag: '🇬🇧',
                  code: 'en',
                  selectedCode: controller.appLanguageCode,
                  onTap: () => controller.updateLanguagePreference('en'),
                ),
                _LanguageOption(
                  title: _text(currentLang, 'russian'),
                  subtitle: _text(currentLang, 'russianSubtitle'),
                  flag: '🇷🇺',
                  code: 'ru',
                  selectedCode: controller.appLanguageCode,
                  onTap: () => controller.updateLanguagePreference('ru'),
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _text(currentLang, 'note'),
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

  static String _languageSubtitle(String code) {
    switch (code) {
      case 'en':
        return 'Selected language: English';
      case 'ru':
        return 'Выбранный язык: Русский';
      case 'tr':
      default:
        return 'Seçili dil: Türkçe';
    }
  }

  static String _text(String code, String key) {
    final language = code == 'en' || code == 'ru' ? code : 'tr';

    const values = {
      'title': {
        'tr': 'Dil',
        'en': 'Language',
        'ru': 'Язык',
      },
      'subtitle': {
        'tr': 'Planora için kullanılacak dili seç. Bu adım çeviri altyapısının güvenli temelidir.',
        'en': 'Choose the language used in Planora. This is the safe foundation for localization.',
        'ru': 'Выберите язык Planora. Это безопасная основа для локализации.',
      },
      'preferenceTitle': {
        'tr': 'Dil tercihi',
        'en': 'Language preference',
        'ru': 'Настройка языка',
      },
      'turkish': {
        'tr': 'Türkçe',
        'en': 'Turkish',
        'ru': 'Турецкий',
      },
      'turkishSubtitle': {
        'tr': 'Varsayılan uygulama dili',
        'en': 'Default app language',
        'ru': 'Язык приложения по умолчанию',
      },
      'english': {
        'tr': 'English',
        'en': 'English',
        'ru': 'Английский',
      },
      'englishSubtitle': {
        'tr': 'İngilizce arayüz tercihi',
        'en': 'English interface preference',
        'ru': 'Предпочтение английского интерфейса',
      },
      'russian': {
        'tr': 'Русский',
        'en': 'Russian',
        'ru': 'Русский',
      },
      'russianSubtitle': {
        'tr': 'Rusça arayüz tercihi',
        'en': 'Russian interface preference',
        'ru': 'Предпочтение русского интерфейса',
      },
      'note': {
        'tr': 'Bu adım sadece Dil ekranındaki metinleri seçili dile göre değiştirir. Diğer ekranlar sonraki küçük patchlerde çevrilecek.',
        'en': 'This step only changes the text on the Language screen. Other screens will be localized in later small patches.',
        'ru': 'Этот шаг меняет только текст на экране языка. Другие экраны будут переведены небольшими патчами позже.',
      },
    };

    return values[key]?[language] ?? values[key]?['tr'] ?? key;
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.code,
    required this.selectedCode,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String flag;
  final String code;
  final String selectedCode;
  final VoidCallback onTap;

  bool get isSelected => code == selectedCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: onTap,
        borderColor: isSelected ? AppColors.brandGreen : AppColors.stroke,
        color: isSelected ? const Color(0xFFE8FFF6) : Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
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
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.brandGreen : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
