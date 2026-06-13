import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A40E0);
  static const Color accent = Color(0xFFFF4D94);
  static const Color accentGreen = Color(0xFF00E5A0);
  static const Color accentOrange = Color(0xFFFF9500);

  // Dark Theme Surfaces
  static const Color darkBg = Color(0xFF080C18);
  static const Color darkSurface = Color(0xFF0F1525);
  static const Color darkCard = Color(0xFF151B2E);
  static const Color darkCardElevated = Color(0xFF1C2440);
  static const Color darkBorder = Color(0xFF252D45);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF8890AA);
  static const Color textHint = Color(0xFF4A5270);

  // Status Colors
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF4D4D);
  static const Color info = Color(0xFF4DA8FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF4D94), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient audioGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4DA8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient videoGradient = LinearGradient(
    colors: [Color(0xFFFF4D94), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bulkGradient = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF4DA8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF080C18), Color(0xFF0D1428)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: darkSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5,
          ),
          displayMedium: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5,
          ),
          headlineLarge: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
          ),
          headlineMedium: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
          ),
          titleLarge: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
          ),
          titleMedium: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
          ),
          labelLarge: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCardElevated,
        selectedColor: primary.withValues(alpha: 0.3),
        side: const BorderSide(color: darkBorder),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
