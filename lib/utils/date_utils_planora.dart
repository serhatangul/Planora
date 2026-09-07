class PlanoraDateUtils {
  const PlanoraDateUtils._();

  static const Map<String, List<String>> _monthNames = {
    'tr': [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    'ru': [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ],
  };

  static List<String> monthNamesFor(String languageCode) {
    return _monthNames[languageCode] ?? _monthNames['tr']!;
  }

  static String monthYearLabel(
    DateTime date, {
    String languageCode = 'tr',
  }) {
    final months = monthNamesFor(languageCode);
    return '${months[date.month - 1]} ${date.year}';
  }

  static DateTime monthOnly(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static int daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  static int firstWeekdayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday - 1;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime safeDateForPayment(DateTime month, int day) {
    final safeDay = day.clamp(1, daysInMonth(month));
    return DateTime(month.year, month.month, safeDay);
  }
}
