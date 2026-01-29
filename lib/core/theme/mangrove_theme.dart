import 'package:flutter/material.dart';

/// Mangrove Theme for IoT Monitoring App
/// Custom theme inspired by the mangrove ecosystem
/// Colors: soft greens, olive tones, off-white backgrounds, muted browns

class MangroveTheme {
  // Primary colors - soft greens from mangrove leaves
  static const Color primaryGreen = Color(0xFF6B8E6B);
  static const Color primaryGreenLight = Color(0xFF8BA88B);
  static const Color primaryGreenDark = Color(0xFF4A6B4A);
  
  // Secondary colors - olive green from mangrove environment
  static const Color oliveGreen = Color(0xFF556B2F);
  static const Color oliveGreenLight = Color(0xFF6B8B47);
  static const Color oliveGreenDark = Color(0xFF3D4D22);
  
  // Background colors - off-white like sandy shores
  static const Color offWhite = Color(0xFFFAF9F6);
  static const Color lightGrey = Color(0xFFF0EDE8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Accent colors - muted brown from mangrove bark
  static const Color mutedBrown = Color(0xFF8B7355);
  static const Color mutedBrownLight = Color(0xFFA69070);
  static const Color mutedBrownDark = Color(0xFF6B5740);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E2C);
  static const Color textSecondary = Color(0xFF5A6B5A);
  static const Color textHint = Color(0xFF8A9B8A);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373);

  /// Creates the main theme data for the app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
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
      
      // Scaffold background
      scaffoldBackgroundColor: offWhite,
      
      // AppBar theme
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
      
      // Card theme with soft rounded corners and subtle shadows
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: primaryGreenDark.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Bottom navigation bar theme
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
      
      // Input decoration theme for forms
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
      
      // Elevated button theme
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
      
      // Text theme
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
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: 24,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: lightGrey,
      ),
    );
  }
}
