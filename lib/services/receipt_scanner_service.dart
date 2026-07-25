import 'package:flutter/services.dart';

import '../models/receipt_scan_result.dart';

class ReceiptScannerException implements Exception {
  const ReceiptScannerException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ReceiptScannerService {
  const ReceiptScannerService._();

  static const MethodChannel _channel =
      MethodChannel('planora/receipt_scanner');

  static Future<ReceiptScanResult?> scanReceipt({
    required List<String> categories,
  }) async {
    try {
      final response =
          await _channel.invokeMapMethod<String, dynamic>('scanReceipt');
      if (response == null) return null;

      final rawText = (response['text'] as String? ?? '').trim();
      if (rawText.isEmpty) {
        throw const ReceiptScannerException(
            'Fişte okunabilir metin bulunamadı.');
      }

      return ReceiptParser.parse(rawText, categories: categories);
    } on PlatformException catch (error) {
      if (error.code == 'CANCELLED') return null;
      throw ReceiptScannerException(
        error.message ?? 'Fiş tarama sırasında beklenmeyen bir hata oluştu.',
      );
    }
  }
}

class ReceiptParser {
  const ReceiptParser._();

  static ReceiptScanResult parse(
    String rawText, {
    required List<String> categories,
  }) {
    final lines = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final merchant = _detectMerchant(lines);
    final currencySymbol = _detectCurrency(rawText);
    final total = _detectTotal(lines);
    final day = _detectDay(rawText);
    final category = _detectCategory(rawText, merchant, categories);

    return ReceiptScanResult(
      rawText: rawText,
      merchant: merchant,
      total: total,
      currencySymbol: currencySymbol,
      day: day,
      suggestedCategory: category,
    );
  }

  static String _detectMerchant(List<String> lines) {
    final ignored = RegExp(
      r'(fiş|fatura|receipt|invoice|tax|vat|vergi|tarih|date|saat|time|cashier|kasa|касс|чек|hóa đơn|ngày)',
      caseSensitive: false,
    );

    for (final line in lines.take(8)) {
      final letters =
          RegExp(r'[A-Za-zÀ-ỹА-Яа-яÇĞİÖŞÜçğıöşü]').allMatches(line).length;
      final digits = RegExp(r'\d').allMatches(line).length;
      if (letters >= 3 &&
          digits < letters &&
          !ignored.hasMatch(line) &&
          line.length <= 48) {
        return _titleCase(line);
      }
    }
    return 'Fiş harcaması';
  }

  static String _detectCurrency(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('₫') ||
        lower.contains(' vnd') ||
        RegExp(r'\d\s*đ\b').hasMatch(lower)) return '₫';
    if (lower.contains('₺') || lower.contains(' try') || lower.contains(' tl'))
      return '₺';
    if (lower.contains('₽') || lower.contains(' rub')) return '₽';
    if (lower.contains('€') || lower.contains(' eur')) return '€';
    if (lower.contains('£') || lower.contains(' gbp')) return '£';
    if (lower.contains('₼') || lower.contains(' azn')) return '₼';
    if (lower.contains('₸') || lower.contains(' kzt')) return '₸';
    if (lower.contains(r'$') || lower.contains(' usd')) return r'$';
    return '';
  }

  static double _detectTotal(List<String> lines) {
    final totalKeywords = RegExp(
      r'(grand\s*total|total\s*due|amount\s*due|total|toplam|genel\s*toplam|ödenecek|итого|к\s*оплате|всего|tổng\s*cộng|thành\s*tiền|tổng\s*thanh\s*toán|phải\s*trả)',
      caseSensitive: false,
    );

    final candidates = <double>[];
    for (final line in lines) {
      if (!totalKeywords.hasMatch(line)) continue;
      candidates.addAll(_amountsIn(line));
    }
    if (candidates.isNotEmpty) {
      return candidates.reduce((a, b) => a > b ? a : b);
    }

    final all = <double>[];
    for (final line in lines) {
      all.addAll(_amountsIn(line));
    }
    if (all.isEmpty) {
      return 0;
    }
    return all.reduce((a, b) => a > b ? a : b);
  }

  static List<double> _amountsIn(String text) {
    final matches = RegExp(
            r'(?<!\d)(\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?)(?!\d)')
        .allMatches(text);
    return matches
        .map((match) => _parseLocalizedNumber(match.group(1) ?? ''))
        .where((value) => value > 0)
        .toList();
  }

  static double _parseLocalizedNumber(String input) {
    var value = input.replaceAll(' ', '').trim();
    if (value.isEmpty) return 0;

    final lastComma = value.lastIndexOf(',');
    final lastDot = value.lastIndexOf('.');
    final lastSeparator = lastComma > lastDot ? lastComma : lastDot;

    if (lastSeparator >= 0) {
      final fractionLength = value.length - lastSeparator - 1;
      final separatorCount = RegExp(r'[.,]').allMatches(value).length;
      final looksDecimal = fractionLength == 1 || fractionLength == 2;

      if (looksDecimal && separatorCount >= 1) {
        final whole =
            value.substring(0, lastSeparator).replaceAll(RegExp(r'[.,]'), '');
        final fraction = value.substring(lastSeparator + 1);
        value = '$whole.$fraction';
      } else {
        value = value.replaceAll(RegExp(r'[.,]'), '');
      }
    }

    return double.tryParse(value) ?? 0;
  }

  static int _detectDay(String text) {
    final dmy =
        RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})\b').firstMatch(text);
    if (dmy != null) {
      return (int.tryParse(dmy.group(1) ?? '') ?? DateTime.now().day)
          .clamp(1, 31);
    }

    final ymd =
        RegExp(r'\b(\d{4})[./-](\d{1,2})[./-](\d{1,2})\b').firstMatch(text);
    if (ymd != null) {
      return (int.tryParse(ymd.group(3) ?? '') ?? DateTime.now().day)
          .clamp(1, 31);
    }

    return DateTime.now().day;
  }

  static String _detectCategory(
      String text, String merchant, List<String> categories) {
    final haystack = '$merchant $text'.toLowerCase();
    final rules = <String, List<String>>{
      'Market': [
        'market',
        'supermarket',
        'grocery',
        'migros',
        'carrefour',
        'coop',
        'winmart',
        'circle k',
        'bách hóa',
        'siêu thị',
        'продукт'
      ],
      'Yeme İçme': [
        'restaurant',
        'cafe',
        'coffee',
        'starbucks',
        'burger',
        'pizza',
        'food',
        'restoran',
        'kafe',
        'nhà hàng',
        'cà phê',
        'кафе',
        'ресторан'
      ],
      'Ulaşım': [
        'shell',
        'petrol',
        'fuel',
        'gas',
        'taxi',
        'grab',
        'uber',
        'metro',
        'transport',
        'xăng',
        'nhiên liệu',
        'такси',
        'бензин'
      ],
      'Sağlık': [
        'pharmacy',
        'eczane',
        'medical',
        'clinic',
        'hospital',
        'nhà thuốc',
        'dược',
        'аптека'
      ],
      'Alışveriş': [
        'store',
        'shop',
        'mall',
        'fashion',
        'clothing',
        'mağaza',
        'shopping',
        'cửa hàng',
        'магазин'
      ],
      'Eğlence': [
        'cinema',
        'movie',
        'game',
        'entertainment',
        'netflix',
        'spotify',
        'rạp',
        'giải trí',
        'кино'
      ],
      'Faturalar': [
        'electric',
        'water',
        'internet',
        'phone',
        'utility',
        'elektrik',
        'fatura',
        'điện',
        'nước',
        'hóa đơn',
        'интернет'
      ],
    };

    for (final entry in rules.entries) {
      if (entry.value.any(haystack.contains)) {
        return _bestExistingCategory(entry.key, categories);
      }
    }

    return _bestExistingCategory('Diğer', categories);
  }

  static String _bestExistingCategory(
      String preferred, List<String> categories) {
    if (categories.contains(preferred)) return preferred;
    final lower = preferred.toLowerCase();
    for (final category in categories) {
      if (category.toLowerCase().contains(lower) ||
          lower.contains(category.toLowerCase())) {
        return category;
      }
    }
    return categories.isNotEmpty ? categories.first : preferred;
  }

  static String _titleCase(String value) {
    return value
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
