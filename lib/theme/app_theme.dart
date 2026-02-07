import 'package:flutter/material.dart';

enum EmberThemeMode { light, dark, feminine }

class AppTheme {
  // === LIGHT MODE EMBER ===
  static const Color lightPrimary = Color(0xFFFF5E00);
  static const Color lightSecondary = Color(0xFFFFC107);
  static const Color lightComplementary = Color(0xFF0A2540);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8FAFC);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightOutline = Color(0xFFE2E8F0);

  // === DARK MODE EMBER (DEFAULT) ===
  static const Color darkPrimary = Color(0xFFFF5E00);
  static const Color darkSecondary = Color(0xFFFFC107);
  static const Color darkComplementary = Color(0xFF0A2540);
  static const Color darkBackground = Color(0xFF0C111A);
  static const Color darkCard = Color(0xFF1A202C);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF2A3441);

  // === FEMININE EMBER ===
  static const Color femininePrimary = Color(0xFFFF6B6B);
  static const Color feminineSecondary = Color(0xFFFF9F9C);
  static const Color feminineComplementary = Color(0xFFF472B6);
  static const Color feminineBackground = Color(0xFFFFF5F5);
  static const Color feminineCard = Color(0xFFFFF0F0);
  static const Color feminineText = Color(0xFF4B5563);
  static const Color feminineTextMuted = Color(0xFF6B7280);
  static const Color feminineOutline = Color(0xFFFBCACA);

  // Backwards compatibility aliases (default to dark mode)
  static const Color primaryOrange = lightPrimary;
  static const Color accentOrange = lightSecondary;
  static const Color backgroundDark = lightBackground;
  static const Color cardDark = lightCard;
  static const Color textPrimaryDark = lightText;
  static const Color textMutedDark = lightTextMuted;
  static const Color outlineDark = lightOutline;

  // Legacy aliases
  static const Color backgroundLight = lightBackground;
  static const Color cardLight = lightCard;
  static const Color primaryPink = femininePrimary;
  static const Color accentCoral = feminineSecondary;
  static const Color textPrimaryLight = lightText;
  static const Color textMutedLight = lightTextMuted;
  static const Color outlineLight = lightOutline;

  // Macro Colors (adapt to current theme)
  static const Color proteinBlue = Color(0xFFFF5E00);
  static const Color carbsAmber = Color(0xFFFFC107);
  static const Color fatsRed = Color(0xFFFF8533);
  static const Color successGreen = Color(0xFFFFC107);

  // Ring Colors
  static const Color caloriesRing = Color(0xFFFF5E00);
  static const Color waterRing = Color(0xFF0A2540);
  static const Color ringTrack = Color(0xFFE2E8F0);

  // Card & Border
  static const Color cardSurface = lightCard;
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Banner Colors
  static const Color bannerGradientStart = Color(0xFFFF5E00);
  static const Color bannerGradientEnd = Color(0xFFFFC107);
  static const Color bannerText = Color(0xFFFFFFFF);
  static const Color bannerIcon = Color(0xFFFFFFFF);

  static ThemeData getTheme(EmberThemeMode mode) {
    switch (mode) {
      case EmberThemeMode.light:
        return _buildLightTheme();
      case EmberThemeMode.dark:
        return _buildDarkTheme();
      case EmberThemeMode.feminine:
        return _buildFeminineTheme();
    }
  }

  // Backwards compatibility
  static ThemeData get darkTheme => _buildLightTheme();
  static ThemeData get lightTheme => _buildLightTheme();

  // === LIGHT MODE THEME ===
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightCard,
        error: fatsRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightText,
      ),
      iconTheme: const IconThemeData(color: lightPrimary, size: 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightPrimary),
        titleTextStyle: TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
          color: lightText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightTextMuted),
        bodySmall: TextStyle(color: lightTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: lightTextMuted),
        hintStyle: const TextStyle(color: lightTextMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightBackground,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextMuted,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightOutline, width: 1),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  // === DARK MODE THEME (DEFAULT) ===
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkCard,
        error: fatsRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkText,
      ),
      iconTheme: const IconThemeData(color: darkPrimary, size: 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkPrimary),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkText),
        bodyMedium: TextStyle(color: darkTextMuted),
        bodySmall: TextStyle(color: darkTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextMuted),
        hintStyle: const TextStyle(color: darkTextMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextMuted,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkOutline, width: 1),
        ),
      ),
    );
  }

  // === FEMININE EMBER THEME ===
  static ThemeData _buildFeminineTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: femininePrimary,
      scaffoldBackgroundColor: feminineBackground,
      cardColor: feminineCard,
      colorScheme: ColorScheme.light(
        primary: femininePrimary,
        secondary: feminineSecondary,
        surface: feminineCard,
        error: femininePrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: feminineText,
      ),
      iconTheme: const IconThemeData(color: femininePrimary, size: 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: feminineBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: femininePrimary),
        titleTextStyle: TextStyle(
          color: feminineText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: femininePrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: femininePrimary,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: feminineText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: feminineText,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: feminineText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: feminineText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(color: feminineText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: feminineText),
        bodyMedium: TextStyle(color: feminineTextMuted),
        bodySmall: TextStyle(color: feminineTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: feminineCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: feminineOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: feminineOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: femininePrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: feminineTextMuted),
        hintStyle: const TextStyle(color: feminineTextMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: feminineBackground,
        selectedItemColor: femininePrimary,
        unselectedItemColor: feminineTextMuted,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: feminineCard,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: feminineOutline, width: 1),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
    );
  }

  // Helper method to get theme based on gender
  static ThemeMode getThemeModeForGender(String? gender) {
    return gender?.toLowerCase() == 'female' ? ThemeMode.light : ThemeMode.dark;
  }
}

// Extension for easy macro color access
extension MacroColorsExtension on BuildContext {
  Color get proteinColor => AppTheme.proteinBlue;
  Color get carbsColor => AppTheme.carbsAmber;
  Color get fatsColor => AppTheme.fatsRed;
  Color get primaryOrange => AppTheme.primaryOrange;
  Color get accentOrange => AppTheme.accentOrange;
}
