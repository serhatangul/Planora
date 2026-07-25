import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../utils/money_formatter.dart';
import '../widgets/premium_widgets.dart';

class CurrencySettingsScreen extends StatelessWidget {
  const CurrencySettingsScreen({super.key});

  static const List<Map<String, String>> _symbols = [
    {'symbol': '₺', 'label': 'Türk Lirası'},
    {'symbol': r'$', 'label': 'Dolar'},
    {'symbol': '€', 'label': 'Euro'},
    {'symbol': '₽', 'label': 'Ruble'},
    {'symbol': '£', 'label': 'Sterlin'},
    {'symbol': '₼', 'label': 'Manat'},
    {'symbol': '₸', 'label': 'Tenge'},
    {'symbol': '₫', 'label': 'Vietnam Dong (VND)'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    MoneyFormatter.setCurrencySymbol(controller.currencySymbol);

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final lang = controller.appLanguageCode;
            MoneyFormatter.setCurrencySymbol(controller.currencySymbol);

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
                        _currencyText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyText(lang, 'subtitle'),
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
                        child: Center(
                          child: Text(
                            controller.currencySymbol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _previewText(lang, controller.formatMoney(12500)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: _currencyText(lang, 'selectCurrency')),
                const SizedBox(height: 12),
                ..._symbols.map(
                  (item) {
                    final symbol = item['symbol'] ?? '₺';
                    final label = item['label'] ?? symbol;
                    final isActive = controller.currencySymbol == symbol;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: isActive
                            ? AppColors.brandGreen.withOpacity(0.50)
                            : AppColors.stroke,
                        child: InkWell(
                          onTap: () async {
                            await controller.updateCurrencySymbol(symbol);
                            MoneyFormatter.setCurrencySymbol(symbol);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE8FFF6)
                                      : AppColors.softBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    symbol,
                                    style: TextStyle(
                                      color: isActive
                                          ? AppColors.brandGreen
                                          : AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 3),
                                    Text(
                                      _exampleText(lang, MoneyFormatter.format(12500, symbol: symbol)),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.brandGreen,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currencyText(lang, 'note'),
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
String _currencyText(String code, String key) {
  final language = {'en', 'ru', 'vi'}.contains(code) ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Para birimi',
      'en': 'Currency',
      'ru': 'Валюта',
      'vi': 'Tiền tệ',
    },
    'subtitle': {
      'tr': 'Tüm tutarlar seçtiğin para birimiyle gösterilir.',
      'en': 'All amounts are shown with the currency you choose.',
      'ru': 'Все суммы отображаются в выбранной валюте.',
      'vi': 'Tất cả số tiền được hiển thị bằng loại tiền bạn chọn.',
    },
    'selectCurrency': {
      'tr': 'Para birimi seç',
      'en': 'Choose currency',
      'ru': 'Выберите валюту',
      'vi': 'Chọn tiền tệ',
    },
    'note': {
      'tr': 'Bu ayar sadece gösterimi değiştirir. Mevcut tutar değerleri dönüştürülmez.',
      'en': 'This setting only changes the display. Existing amount values are not converted.',
      'ru': 'Эта настройка меняет только отображение. Существующие суммы не конвертируются.',
      'vi': 'Cài đặt này chỉ thay đổi cách hiển thị. Các số tiền hiện có không được quy đổi.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _previewText(String code, String amount) {
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

String _exampleText(String code, String amount) {
  switch (code) {
    case 'en':
      return 'Example: $amount';
    case 'ru':
      return 'Пример: $amount';
    case 'tr':
    default:
      return 'Örnek: $amount';
  }
}


}
