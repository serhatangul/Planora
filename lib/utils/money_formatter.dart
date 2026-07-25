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

    final rounded = value.round();
    final isNegative = rounded < 0;
    final raw = rounded.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-' : ''}$selectedSymbol${buffer.toString()}';
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
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0;
  }
}
