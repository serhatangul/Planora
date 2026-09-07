class MoneyFormatter {
  const MoneyFormatter._();

  static String currencySymbol = '₺';
  static bool hideAmounts = false;

  static void setCurrencySymbol(String symbol) {
    currencySymbol = symbol.trim().isEmpty ? '₺' : symbol.trim();
  }

  static void setHideAmounts(bool value) {
    hideAmounts = value;
  }

  static String format(num value, {String? symbol, bool forceVisible = false}) {
    final selectedSymbol = symbol ?? currencySymbol;

    if (hideAmounts && !forceVisible) {
      return '$selectedSymbol••••';
    }

    final numericValue = value.toDouble();
    final isNegative = numericValue < 0;
    final absoluteValue = numericValue.abs();

    String formatted;

    if (absoluteValue > 0 && absoluteValue < 1) {
      formatted = absoluteValue < 0.01
          ? absoluteValue.toStringAsFixed(4)
          : absoluteValue.toStringAsFixed(2);

      formatted = formatted
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    } else {
      final rounded = absoluteValue.round();
      final raw = rounded.toString();
      final buffer = StringBuffer();

      for (int i = 0; i < raw.length; i++) {
        final reverseIndex = raw.length - i;
        buffer.write(raw[i]);

        if (reverseIndex > 1 && reverseIndex % 3 == 1) {
          buffer.write('.');
        }
      }

      formatted = buffer.toString();
    }

    if (selectedSymbol == '₫') {
      return '${isNegative ? '-' : ''}$formatted ₫';
    }

    return '${isNegative ? '-' : ''}$selectedSymbol$formatted';
  }

  static double parseAmount(String value) {
    final normalized = value
        .replaceAll(currencySymbol, '')
        .replaceAll('₺', '')
        .replaceAll('₽', '')
        .replaceAll(r'$', '')
        .replaceAll('€', '')
        .replaceAll('£', '')
        .replaceAll('₼', '')
        .replaceAll('₸', '')
        .replaceAll('₫', '')
        .replaceAll('VND', '')
        .replaceAll('vnd', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0;
  }
}
