import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateException implements Exception {
  const ExchangeRateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExchangeRateService {
  const ExchangeRateService._();

  static const Map<String, String> symbolToCode = {
    '₺': 'TRY',
    r'$': 'USD',
    '€': 'EUR',
    '₽': 'RUB',
    '£': 'GBP',
    '₼': 'AZN',
    '₸': 'KZT',
    '₫': 'VND',
  };

  static String? currencyCodeForSymbol(String symbol) {
    return symbolToCode[symbol];
  }

  static Future<double> _fetchDirectRate({
    required String from,
    required String to,
  }) async {
    if (from == to) return 1.0;

    final uri = Uri.https(
      'api.frankfurter.dev',
      '/v2/rate/$from/$to',
    );

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw ExchangeRateException(
        'Exchange-rate server returned HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const ExchangeRateException(
        'Invalid exchange-rate response.',
      );
    }

    final value = decoded['rate'];

    if (value is! num || value <= 0) {
      throw ExchangeRateException(
        'No valid exchange rate found for $from → $to.',
      );
    }

    return value.toDouble();
  }

  static Future<double> getRate({
    required String fromSymbol,
    required String toSymbol,
  }) async {
    final from = currencyCodeForSymbol(fromSymbol);
    final to = currencyCodeForSymbol(toSymbol);

    if (from == null) {
      throw ExchangeRateException(
        'Unsupported source currency: $fromSymbol',
      );
    }

    if (to == null) {
      throw ExchangeRateException(
        'Unsupported target currency: $toSymbol',
      );
    }

    if (from == to) return 1.0;

    try {
      return await _fetchDirectRate(
        from: from,
        to: to,
      );
    } catch (_) {
      // Direct pair başarısız olursa USD üzerinden çapraz kur hesapla.
      try {
        final fromToUsd = from == 'USD'
            ? 1.0
            : await _fetchDirectRate(
                from: from,
                to: 'USD',
              );

        final usdToTarget = to == 'USD'
            ? 1.0
            : await _fetchDirectRate(
                from: 'USD',
                to: to,
              );

        final crossRate = fromToUsd * usdToTarget;

        if (crossRate <= 0 || crossRate.isNaN || crossRate.isInfinite) {
          throw const ExchangeRateException(
            'Invalid cross exchange rate.',
          );
        }

        return crossRate;
      } catch (error) {
        throw ExchangeRateException(
          'Could not load exchange rate: $error',
        );
      }
    }
  }

  static Future<double> convert({
    required double amount,
    required String fromSymbol,
    required String toSymbol,
  }) async {
    final rate = await getRate(
      fromSymbol: fromSymbol,
      toSymbol: toSymbol,
    );

    return amount * rate;
  }
}
