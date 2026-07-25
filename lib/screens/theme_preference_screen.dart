import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class ThemePreferenceScreen extends StatelessWidget {
  const ThemePreferenceScreen({super.key});

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
                        _themeText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _themeText(lang, 'subtitle'),
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
                          gradient: controller.preferDarkMode
                              ? AppGradients.premiumDark
                              : AppGradients.brand,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          controller.preferDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.preferDarkMode
                                  ? _themeText(lang, 'darkSelected')
                                  : _themeText(lang, 'lightSelected'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.preferDarkMode
                                  ? _themeText(lang, 'darkSubtitle')
                                  : _themeText(lang, 'lightSubtitle'),
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
                      Switch.adaptive(
                        value: controller.preferDarkMode,
                        activeColor: AppColors.brandGreen,
                        onChanged: (value) => controller.updateThemePreference(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeChoiceCard(
                        title: _themeText(lang, 'light'),
                        subtitle: _themeText(lang, 'currentView'),
                        icon: Icons.light_mode_rounded,
                        selected: !controller.preferDarkMode,
                        onTap: () => controller.updateThemePreference(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeChoiceCard(
                        title: _themeText(lang, 'dark'),
                        subtitle: _themeText(lang, 'preparationPreference'),
                        icon: Icons.dark_mode_rounded,
                        selected: controller.preferDarkMode,
                        onTap: () => controller.updateThemePreference(true),
                      ),
                    ),
                  ],
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
                          _themeText(lang, 'note'),
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


String _themeText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Tema',
      'en': 'Theme',
      'ru': 'Тема',
    },
    'subtitle': {
      'tr': 'Planora için görünüm tercihini hazırla. Bu adım koyu mod geçişinin güvenli temelidir.',
      'en': 'Prepare the appearance preference for Planora. This step is the safe foundation for dark mode transition.',
      'ru': 'Настройте предпочтение внешнего вида Planora. Этот шаг является безопасной основой для перехода к тёмному режиму.',
    },
    'darkSelected': {
      'tr': 'Koyu mod tercihi seçildi',
      'en': 'Dark mode preference selected',
      'ru': 'Выбрана тёмная тема',
    },
    'lightSelected': {
      'tr': 'Açık mod tercihi seçildi',
      'en': 'Light mode preference selected',
      'ru': 'Выбрана светлая тема',
    },
    'darkSubtitle': {
      'tr': 'Bir sonraki adımda uygulama ekranları koyu moda bağlanacak.',
      'en': 'In the next step, app screens will be connected to dark mode.',
      'ru': 'На следующем этапе экраны приложения будут подключены к тёмному режиму.',
    },
    'lightSubtitle': {
      'tr': 'Şu an uygulama açık modda çalışmaya devam eder.',
      'en': 'For now, the app continues to work in light mode.',
      'ru': 'Сейчас приложение продолжает работать в светлом режиме.',
    },
    'light': {
      'tr': 'Açık',
      'en': 'Light',
      'ru': 'Светлая',
    },
    'currentView': {
      'tr': 'Mevcut görünüm',
      'en': 'Current appearance',
      'ru': 'Текущий вид',
    },
    'dark': {
      'tr': 'Koyu',
      'en': 'Dark',
      'ru': 'Тёмная',
    },
    'preparationPreference': {
      'tr': 'Hazırlık tercihi',
      'en': 'Preparation preference',
      'ru': 'Подготовительная настройка',
    },
    'note': {
      'tr': 'Bu patch sadece tema tercihini kaydeder. Uygulamanın tamamı henüz koyu moda geçmez. Böylece önce build ve storage güvenliğini test etmiş oluruz.',
      'en': 'This patch only saves the theme preference. The entire app does not switch to dark mode yet. This lets us test build and storage safety first.',
      'ru': 'Этот патч только сохраняет выбор темы. Всё приложение пока не переходит в тёмный режим. Так мы сначала проверяем безопасность сборки и хранения данных.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _ThemeChoiceCard extends StatelessWidget {
  const _ThemeChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      borderColor: selected ? AppColors.brandGreen : AppColors.stroke,
      color: selected ? const Color(0xFFE8FFF6) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.brandGreen : AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.brandGreen : AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
