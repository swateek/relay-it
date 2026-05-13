class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "Today", "Yesterday", or "May 10" / "Apr 3, 2025" depending on the year.
  static String groupLabel(DateTime date, {DateTime? now}) {
    final today = _atMidnight(now ?? DateTime.now());
    final target = _atMidnight(date);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (target.year == today.year) {
      return '${_monthsShort[target.month - 1]} ${target.day}';
    }
    return '${_monthsShort[target.month - 1]} ${target.day}, ${target.year}';
  }

  /// 12-hour "h:mm AM/PM"
  static String time(DateTime date) {
    final isPm = date.hour >= 12;
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute ${isPm ? 'PM' : 'AM'}';
  }

  /// "Today, 9:14 PM" style line for a log row.
  static String relativeAndTime(DateTime date, {DateTime? now}) {
    return '${groupLabel(date, now: now)}, ${time(date)}';
  }

  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);
}
