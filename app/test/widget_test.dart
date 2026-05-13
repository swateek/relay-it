import 'package:flutter_test/flutter_test.dart';
import 'package:relayit/core/utils/date_formatter.dart';
import 'package:relayit/core/utils/otp_extractor.dart';

void main() {
  group('DateFormatter', () {
    test('groupLabel returns Today / Yesterday correctly', () {
      final now = DateTime(2026, 5, 13, 9, 0);
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 13, 1), now: now),
        'Today',
      );
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 12, 23), now: now),
        'Yesterday',
      );
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 10), now: now),
        'May 10',
      );
      expect(
        DateFormatter.groupLabel(DateTime(2024, 4, 3), now: now),
        'Apr 3, 2024',
      );
    });

    test('time formats 12-hour clock', () {
      expect(DateFormatter.time(DateTime(2026, 1, 1, 0, 5)), '12:05 AM');
      expect(DateFormatter.time(DateTime(2026, 1, 1, 14, 30)), '2:30 PM');
    });
  });

  group('OtpExtractor', () {
    test('extracts the digit group following an OTP hint', () {
      expect(
        OtpExtractor.extract('Your OTP is 482910. Do not share.'),
        '482910',
      );
    });

    test('returns null when the body has no digit run', () {
      expect(OtpExtractor.extract('No code here'), isNull);
    });

    test('falls back to the first digit group when no hint is present', () {
      expect(OtpExtractor.extract('Token 1234 is yours.'), '1234');
    });
  });
}
