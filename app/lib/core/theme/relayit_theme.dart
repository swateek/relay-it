import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  Relayit — brand colour tokens
//  Inspired by Anthropic / Claude design language
// ─────────────────────────────────────────────

class RelayitColors {
  RelayitColors._();

  // ── Accent (terracotta / coral) ──────────────
  static const Color accent = Color(0xFFC96442);
  static const Color accentLight = Color(0xFFFAECE7); // bg tint
  static const Color accentDark = Color(0xFF712B13); // text on light tint
  static const Color accentBorder = Color(0x40C96442); // 25 % alpha border

  // ── Neutrals – light mode ────────────────────
  static const Color bgPage = Color(0xFFF5F0EB); // warm off-white page
  static const Color bgSurface = Color(0xFFFDFAF7); // app-bar / nav-bar
  static const Color bgCard = Color(0xFFFFFFFF); // card fill
  static const Color bgMuted = Color(0xFFF1EFE8); // icon bg, muted chips

  static const Color textPrimary = Color(0xFF1A1310);
  static const Color textSecondary = Color(0xFF6B5B4E);
  static const Color textHint = Color(0xFFA8978A);

  static const Color borderSubtle = Color(0x21583C28); // ~13 % warm brown
  static const Color borderMedium = Color(0x38583C28); // ~22 %
  static const Color toggleOff = Color(0xFFD3C8BE);

  // ── Semantic ─────────────────────────────────
  static const Color success = Color(0xFF2A7A52);
  static const Color successBg = Color(0xFFE4F3EC);
  static const Color error = Color(0xFFB03030);
  static const Color errorBg = Color(0xFFFCEBEB);

  // ── Channel icon tints ───────────────────────
  static const Color tealBg = Color(0xFFE1F5EE);
  static const Color tealFg = Color(0xFF0F6E56);
  static const Color sandBg = Color(0xFFF1EFE8);
  static const Color sandFg = Color(0xFF5F5E5A);

  // ── Dark-mode overrides ──────────────────────
  static const Color darkBgPage = Color(0xFF1A1410);
  static const Color darkBgSurface = Color(0xFF221C17);
  static const Color darkBgCard = Color(0xFF2C2318);
  static const Color darkBgMuted = Color(0xFF332820);

  static const Color darkText1 = Color(0xFFF5EDE6);
  static const Color darkText2 = Color(0xFFB09A8C);
  static const Color darkText3 = Color(0xFF7A6358);

  static const Color darkBorder = Color(0x29C9A882); // ~16 % warm gold
  static const Color darkBorderMd = Color(0x3DC9A882); // ~24 %
  static const Color darkToggleOff = Color(0xFF4A3B30);
}

// ─────────────────────────────────────────────
//  Text styles
//  • Display / wordmark → serif (Playfair Display)
//  • Everything else   → sans  (DM Sans)
// ─────────────────────────────────────────────

class RelayitTextStyles {
  RelayitTextStyles._();

  static TextStyle wordmark({Color color = RelayitColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle appBarTitle({Color color = RelayitColors.textPrimary}) =>
      GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body({Color color = RelayitColors.textPrimary}) =>
      GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMedium({Color color = RelayitColors.textPrimary}) =>
      GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle caption({Color color = RelayitColors.textSecondary}) =>
      GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label({Color color = RelayitColors.textHint}) =>
      GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.6,
      );
}

// ─────────────────────────────────────────────
//  ThemeData factory
// ─────────────────────────────────────────────

class RelayitTheme {
  RelayitTheme._();

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isLight = brightness == Brightness.light;

    final Color bgPage = isLight
        ? RelayitColors.bgPage
        : RelayitColors.darkBgPage;
    final Color bgSurface = isLight
        ? RelayitColors.bgSurface
        : RelayitColors.darkBgSurface;
    final Color bgCard = isLight
        ? RelayitColors.bgCard
        : RelayitColors.darkBgCard;
    final Color txt1 = isLight
        ? RelayitColors.textPrimary
        : RelayitColors.darkText1;
    final Color txt2 = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    final Color border = isLight
        ? RelayitColors.borderSubtle
        : RelayitColors.darkBorder;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: RelayitColors.accent,
      onPrimary: Colors.white,
      primaryContainer: RelayitColors.accentLight,
      onPrimaryContainer: RelayitColors.accentDark,
      secondary: RelayitColors.accentLight,
      onSecondary: RelayitColors.accentDark,
      secondaryContainer: RelayitColors.accentLight,
      onSecondaryContainer: RelayitColors.accentDark,
      surface: bgCard,
      onSurface: txt1,
      surfaceContainerHighest: isLight
          ? RelayitColors.bgMuted
          : RelayitColors.darkBgMuted,
      error: RelayitColors.error,
      onError: Colors.white,
      outline: border,
      outlineVariant: isLight
          ? RelayitColors.borderMedium
          : RelayitColors.darkBorderMd,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // ── Page background ──────────────────────
      scaffoldBackgroundColor: bgPage,

      // ── App bar ──────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgSurface,
        foregroundColor: txt1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: RelayitTextStyles.appBarTitle(color: txt1),
        iconTheme: IconThemeData(color: txt2, size: 22),
        shape: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),

      // ── Bottom navigation ─────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgSurface,
        selectedItemColor: RelayitColors.accent,
        unselectedItemColor: txt2,
        selectedLabelStyle: RelayitTextStyles.caption(
          color: RelayitColors.accent,
        ),
        unselectedLabelStyle: RelayitTextStyles.caption(color: txt2),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Cards ─────────────────────────────────
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 0.5),
        ),
      ),

      // ── Divider ───────────────────────────────
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),

      // ── Input fields ──────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        hintStyle: RelayitTextStyles.body(color: txt2),
        labelStyle: RelayitTextStyles.caption(color: txt2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isLight
                ? RelayitColors.borderMedium
                : RelayitColors.darkBorderMd,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: RelayitColors.accent, width: 1),
        ),
      ),

      // ── Elevated / filled buttons (primary CTA) ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RelayitColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: RelayitTextStyles.bodyMedium(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── Outlined buttons (ghost / secondary) ─────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txt2,
          side: BorderSide(color: border, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: RelayitTextStyles.body(color: txt2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── Text buttons ──────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RelayitColors.accent,
          textStyle: RelayitTextStyles.body(color: RelayitColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── FAB ───────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RelayitColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: StadiumBorder(),
      ),

      // ── Switch (toggle) ───────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? RelayitColors.accent
              : (isLight
                    ? RelayitColors.toggleOff
                    : RelayitColors.darkToggleOff),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Chip ──────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? RelayitColors.bgMuted
            : RelayitColors.darkBgMuted,
        side: BorderSide(color: border, width: 0.5),
        labelStyle: RelayitTextStyles.caption(color: txt2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const StadiumBorder(),
      ),

      // ── List tile ─────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: txt2,
        titleTextStyle: RelayitTextStyles.bodyMedium(color: txt1),
        subtitleTextStyle: RelayitTextStyles.caption(color: txt2),
        minVerticalPadding: 10,
        contentPadding: EdgeInsets.zero,
      ),

      // ── Icon ──────────────────────────────────────
      iconTheme: IconThemeData(color: txt2, size: 20),

      // ── Text ──────────────────────────────────────
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: RelayitTextStyles.wordmark(color: txt1),
        titleLarge: RelayitTextStyles.appBarTitle(color: txt1),
        titleMedium: RelayitTextStyles.bodyMedium(color: txt1),
        bodyLarge: RelayitTextStyles.body(color: txt1),
        bodyMedium: RelayitTextStyles.body(color: txt2),
        bodySmall: RelayitTextStyles.caption(color: txt2),
        labelSmall: RelayitTextStyles.label(
          color: isLight ? RelayitColors.textHint : RelayitColors.darkText3,
        ),
      ),

      // ── Page transitions ──────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
    );
  }
}
