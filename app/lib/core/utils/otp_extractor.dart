class OtpExtractor {
  OtpExtractor._();

  static final RegExp _digitGroup = RegExp(r'\b\d{4,8}\b');

  static final RegExp _hint = RegExp(
    r'\b(otp|one[\s-]?time[\s-]?password|verification code|verify code|secure code|auth code|passcode|code is|code:)\b',
    caseSensitive: false,
  );

  /// Returns an OTP-looking digit group from [body], or null.
  ///
  /// Prefers the digit group nearest an OTP hint word. Falls back to the
  /// first 4-8 digit run if no hint is present.
  static String? extract(String? body) {
    if (body == null || body.isEmpty) return null;
    final hintMatch = _hint.firstMatch(body);
    if (hintMatch != null) {
      final searchStart = hintMatch.end;
      final after = _digitGroup.firstMatch(body.substring(searchStart));
      if (after != null) return after.group(0);
      final any = _digitGroup.firstMatch(body);
      if (any != null) return any.group(0);
      return null;
    }
    final first = _digitGroup.firstMatch(body);
    return first?.group(0);
  }
}
