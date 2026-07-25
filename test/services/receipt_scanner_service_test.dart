import 'package:flutter_test/flutter_test.dart';
import 'package:planora/services/receipt_scanner_service.dart';

void main() {
  const categories = <String>[
    'Market',
    'Yeme İçme',
    'Ulaşım',
    'Sağlık',
    'Alışveriş',
    'Eğlence',
    'Faturalar',
    'Diğer',
  ];

  group('ReceiptParser.parse', () {
    test('Vietnam fişinde receipt numarasını toplam kabul etmez', () {
      const rawText = '''
Terminal No: 303
Receipt No: 000000030300006091
Trans Date: 25/07/2026
Total Qty: 2
Subtotal
4,980,000
TOTAL
4,980,000 VND
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 4980000);
      expect(result.currencySymbol, '₫');
      expect(result.day, 25);
      expect(result.merchant, isNot('Terminal No: 303'));
    });

    test('uzun terminal ve işlem numaralarını para saymaz', () {
      const rawText = '''
Terminal Number: 123456789012345678
Transaction ID: 987654321098765432
Grand Total: 1,250,000 VND
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 1250000);
    });

    test('Türkçe fişte genel toplamı bulur', () {
      const rawText = '''
ÖRNEK MARKET
Tarih: 25.07.2026
Fiş No: 123456789012345
Ara Toplam: 845,50 TL
KDV: 84,55 TL
GENEL TOPLAM: 930,05 TL
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 930.05);
      expect(result.currencySymbol, '₺');
      expect(result.day, 25);
      expect(result.merchant, 'Örnek Market');
    });

    test('Rusça fişte ödeme toplamını bulur', () {
      const rawText = '''
ПРОДУКТЫ МАРКЕТ
Дата: 25.07.2026
Номер чека: 456789012345678
К ОПЛАТЕ: 1 520,50 RUB
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 1520.50);
      expect(result.currencySymbol, '₽');
      expect(result.day, 25);
    });

    test('tarih ve telefon numarasını toplam kabul etmez', () {
      const rawText = '''
CAFE EXAMPLE
Phone: 0901234567
Date: 25/07/2026
Total: 250,000 VND
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 250000);
      expect(result.merchant, 'Cafe Example');
    });

    test('toplam bulunamazsa sıfır döndürür', () {
      const rawText = '''
Receipt No: 000000030300006091
Terminal No: 303
Staff No: 25
''';

      final result = ReceiptParser.parse(
        rawText,
        categories: categories,
      );

      expect(result.total, 0);
    });
  });
}
