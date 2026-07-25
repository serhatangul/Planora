class PlanoraDateUtils {
  const PlanoraDateUtils._();

  static const List<String> monthNamesTr = [
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
  ];

  static String monthYearLabel(DateTime date) {
    return '${monthNamesTr[date.month - 1]} ${date.year}';
  }

  static DateTime monthOnly(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static int daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  /// Flutter DateTime weekday: Monday 1 ... Sunday 7.
  /// App calendar starts with Monday, so offset is 0 for Monday.
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
