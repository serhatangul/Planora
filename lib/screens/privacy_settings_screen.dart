import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

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
                        _privacyText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _privacyText(lang, 'subtitle'),
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
                        child: Icon(
                          controller.hideAmounts
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          controller.hideAmounts
                              ? _privacyText(lang, 'amountsHidden')
                              : _privacyText(lang, 'amountsVisible'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PremiumCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF0FB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_rounded,
                          color: AppColors.brandBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_privacyText(lang, 'hiddenAmountMode'), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              controller.hideAmounts
                                  ? _hiddenAmountFormatText(lang)
                                  : _privacyText(lang, 'normalAmounts'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: controller.hideAmounts,
                        activeColor: AppColors.brandGreen,
                        onChanged: controller.updateHideAmounts,
                      ),
                    ],
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
                          _privacyText(lang, 'infoNote'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: const Color(0xFFF4FFFB),
                  borderColor: AppColors.brandGreen.withOpacity(0.22),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye_rounded, color: AppColors.brandGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _privacyExampleText(lang, MoneyFormatter.format(12500)),
                          style: Theme.of(context).textTheme.titleMedium,
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
String _privacyText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Gizlilik',
      'en': 'Privacy',
      'ru': 'Приватность',
    },
    'subtitle': {
      'tr': 'Telefonu başkasının yanında açtığında finans tutarlarını gizleyebilirsin.',
      'en': 'You can hide financial amounts when opening the app around others.',
      'ru': 'Вы можете скрывать финансовые суммы, когда открываете приложение рядом с другими.',
    },
    'amountsHidden': {
      'tr': 'Tutarlar gizli.',
      'en': 'Amounts are hidden.',
      'ru': 'Суммы скрыты.',
    },
    'amountsVisible': {
      'tr': 'Tutarlar görüntüleniyor.',
      'en': 'Amounts are shown.',
      'ru': 'Суммы отображаются.',
    },
    'hiddenAmountMode': {
      'tr': 'Gizli tutar modu',
      'en': 'Hidden amount mode',
      'ru': 'Режим скрытых сумм',
    },
    'normalAmounts': {
      'tr': 'Tutarlar normal şekilde gösterilir.',
      'en': 'Amounts are shown normally.',
      'ru': 'Суммы отображаются.',
    },
    'infoNote': {
      'tr': 'Bu mod sadece ekrandaki tutarları gizler. Kayıtlı veriler silinmez veya değişmez.',
      'en': 'This mode only hides amounts on the screen. Saved data is not deleted or changed.',
      'ru': 'Этот режим только скрывает суммы на экране. Сохранённые данные не удаляются и не изменяются.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _hiddenAmountFormatText(String code) {
  final symbol = MoneyFormatter.currencySymbol;

  switch (code) {
    case 'en':
      return 'Amounts are shown as $symbol••••.';
    case 'ru':
      return 'Суммы отображаются как $symbol••••.';
    case 'tr':
    default:
      return 'Tutarlar $symbol•••• şeklinde gösterilir.';
  }
}

String _privacyExampleText(String code, String amount) {
  switch (code) {
    case 'en':
      return 'Preview: $amount';
    case 'ru':
      return 'Пример: $amount';
    case 'tr':
    default:
      return 'Örnek görünüm: $amount';
  }
}


}
