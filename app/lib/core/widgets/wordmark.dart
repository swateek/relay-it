import 'package:flutter/material.dart';

import '../theme/relayit_theme.dart';

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize});

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = brightness == Brightness.light
        ? RelayitColors.textPrimary
        : RelayitColors.darkText1;
    final relayStyle = RelayitTextStyles.wordmark(
      color: primaryColor,
    ).copyWith(fontSize: fontSize);
    final itStyle = RelayitTextStyles.wordmark(
      color: RelayitColors.accent,
    ).copyWith(fontSize: fontSize);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'relay', style: relayStyle),
          TextSpan(text: 'it', style: itStyle),
        ],
      ),
    );
  }
}
