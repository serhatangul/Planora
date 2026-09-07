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
      backgroundColor: AppThemeColors.background(context),
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
                          color: Colors.white.withValues(alpha: 0.10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currencyText(lang, 'primaryCurrency'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _previewText(
                                lang,
                                controller.formatMoney(12500),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: _currencyText(lang, 'selectCurrency'),
                ),
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
                            ? AppColors.brandGreen.withValues(alpha: 0.50)
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
                                    Text(
                                      label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _exampleText(
                                        lang,
                                        MoneyFormatter.format(
                                          12500,
                                          symbol: symbol,
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
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
                const SizedBox(height: 18),
                SectionHeader(
                  title: _currencyText(lang, 'secondaryCurrency'),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyText(lang, 'secondaryCurrencySubtitle'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F7FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                controller.secondaryCurrencySymbol,
                                style: const TextStyle(
                                  fontSize: 23,
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
                                Text(
                                  '${controller.currencySymbol}1 = '
                                  '${controller.secondaryExchangeRateText} '
                                  '${controller.secondaryCurrencySymbol}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.secondaryCurrencyRate > 0
                                      ? _secondaryExampleText(
                                          lang,
                                          controller.formatMoney(100),
                                          controller.formatSecondaryMoney(100),
                                        )
                                      : _currencyText(lang, 'rateUnavailable'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: controller.isSecondaryCurrencyRateLoading
                                ? null
                                : () {
                                    controller.refreshSecondaryCurrencyRate();
                                  },
                            icon: controller.isSecondaryCurrencyRateLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      if (controller.secondaryCurrencyRateError != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _currencyText(lang, 'rateError'),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._symbols
                    .where(
                  (item) => item['symbol'] != controller.currencySymbol,
                )
                    .map(
                  (item) {
                    final symbol = item['symbol'] ?? '₫';
                    final label = item['label'] ?? symbol;
                    final isActive =
                        controller.secondaryCurrencySymbol == symbol;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: isActive
                            ? AppColors.brandBlue.withValues(alpha: 0.45)
                            : AppColors.stroke,
                        child: InkWell(
                          onTap: () async {
                            await controller
                                .updateSecondaryCurrencySymbol(symbol);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFF1F7FF)
                                      : AppColors.softBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    symbol,
                                    style: TextStyle(
                                      color: isActive
                                          ? AppColors.brandBlue
                                          : AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  label,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (isActive)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.brandBlue,
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
                      const Icon(
                        Icons.info_rounded,
                        color: AppColors.brandBlue,
                      ),
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
        'tr':
            'Ana para birimini ve harcamalarda görmek istediğin ikinci para birimini seç.',
        'en':
            'Choose your primary currency and a second currency for expense conversion.',
        'ru':
            'Выберите основную валюту и вторую валюту для конвертации расходов.',
        'vi': 'Chọn tiền tệ chính và tiền tệ thứ hai để quy đổi chi tiêu.',
      },
      'primaryCurrency': {
        'tr': 'Ana para birimi',
        'en': 'Primary currency',
        'ru': 'Основная валюта',
        'vi': 'Tiền tệ chính',
      },
      'selectCurrency': {
        'tr': 'Ana para birimini seç',
        'en': 'Choose primary currency',
        'ru': 'Выберите основную валюту',
        'vi': 'Chọn tiền tệ chính',
      },
      'secondaryCurrency': {
        'tr': 'İkinci para birimi',
        'en': 'Secondary currency',
        'ru': 'Вторая валюта',
        'vi': 'Tiền tệ thứ hai',
      },
      'secondaryCurrencySubtitle': {
        'tr':
            'Harcama tutarlarının altında güncel kura göre karşılığını göstermek için kullanılır.',
        'en':
            'Used to show converted values below expense amounts using the latest exchange rate.',
        'ru':
            'Используется для отображения пересчитанной суммы расходов по актуальному курсу.',
        'vi':
            'Dùng để hiển thị số tiền quy đổi bên dưới chi tiêu theo tỷ giá mới nhất.',
      },
      'rateUnavailable': {
        'tr': 'Kur henüz yüklenmedi.',
        'en': 'Exchange rate has not loaded yet.',
        'ru': 'Курс пока не загружен.',
        'vi': 'Tỷ giá chưa được tải.',
      },
      'rateError': {
        'tr':
            'Kur alınamadı. İnternet bağlantını kontrol edip tekrar deneyebilirsin.',
        'en':
            'Could not load the exchange rate. Check your connection and try again.',
        'ru':
            'Не удалось загрузить курс. Проверьте соединение и попробуйте снова.',
        'vi': 'Không thể tải tỷ giá. Hãy kiểm tra kết nối và thử lại.',
      },
      'note': {
        'tr':
            'Ana para birimi kayıtların temel para birimidir. İkinci para birimi yalnızca güncel kur üzerinden ek gösterim sağlar; kayıtlı tutarları değiştirmez.',
        'en':
            'The primary currency remains the base currency of your records. The secondary currency only adds a live converted display and does not change stored amounts.',
        'ru':
            'Основная валюта остаётся базовой валютой записей. Вторая валюта только показывает пересчитанную сумму и не изменяет сохранённые значения.',
        'vi':
            'Tiền tệ chính vẫn là tiền tệ cơ sở của dữ liệu. Tiền tệ thứ hai chỉ hiển thị giá trị quy đổi và không thay đổi số tiền đã lưu.',
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
      case 'vi':
        return 'Xem trước: $amount';
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
      case 'vi':
        return 'Ví dụ: $amount';
      case 'tr':
      default:
        return 'Örnek: $amount';
    }
  }

  String _secondaryExampleText(
    String code,
    String primaryAmount,
    String secondaryAmount,
  ) {
    switch (code) {
      case 'en':
        return '$primaryAmount ≈ $secondaryAmount';
      case 'ru':
        return '$primaryAmount ≈ $secondaryAmount';
      case 'vi':
        return '$primaryAmount ≈ $secondaryAmount';
      case 'tr':
      default:
        return '$primaryAmount ≈ $secondaryAmount';
    }
  }
}
