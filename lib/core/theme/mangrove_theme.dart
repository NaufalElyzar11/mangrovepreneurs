import 'package:flutter/material.dart';

class MangroveTheme {
  static const Color primaryGreen = Color(0xFF6B8E6B);
  static const Color primaryGreenLight = Color(0xFF8BA88B);
  static const Color primaryGreenDark = Color(0xFF4A6B4A);
  
  static const Color oliveGreen = Color(0xFF556B2F);
  static const Color oliveGreenLight = Color(0xFF6B8B47);
  static const Color oliveGreenDark = Color(0xFF3D4D22);
  
  static const Color offWhite = Color(0xFFFAF9F6);
  static const Color lightGrey = Color(0xFFF0EDE8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  static const Color mutedBrown = Color(0xFF8B7355);
  static const Color mutedBrownLight = Color(0xFFA69070);
  static const Color mutedBrownDark = Color(0xFF6B5740);
  
  static const Color textPrimary = Color(0xFF2C3E2C);
  static const Color textSecondary = Color(0xFF5A6B5A);
  static const Color textHint = Color(0xFF8A9B8A);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: primaryGreenLight,
        onPrimaryContainer: primaryGreenDark,
        secondary: oliveGreen,
        onSecondary: Colors.white,
        secondaryContainer: oliveGreenLight,
        onSecondaryContainer: oliveGreenDark,
        tertiary: mutedBrown,
        onTertiary: Colors.white,
        tertiaryContainer: mutedBrownLight,
        onTertiaryContainer: mutedBrownDark,
        surface: offWhite,
        onSurface: textPrimary,
        surfaceContainerHighest: lightGrey,
        error: error,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: offWhite,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: primaryGreenDark.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textHint),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textHint,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),
      
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: 24,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: lightGrey,
      ),
    );
  }
}
