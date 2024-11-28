import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF6C5CE7); // Modern Purple
  static const secondary = Color(0xFF00D2D3); // Bright Cyan
  static const background = Color(0xFF1A1B1E); // Dark Background
  static const surface = Color(0xFF2D2D34); // Card Background
  static const error = Color(0xFFFF6B6B); // Soft Red

  // Task Status Colors
  static const pending = Color(0xFFFFA502); // Warm Orange
  static const inProgress = Color(0xFF45AAF2); // Bright Blue
  static const completed = Color(0xFF2ECC71); // Fresh Green
  static const postponed = Color(0xFFFF7675); // Coral Red

  // Text Colors
  static const textPrimary = Color(0xFFF5F6FA); // Almost White
  static const textSecondary = Color(0xFFA4A5A7); // Muted Gray
  static const textLight = Color(0xFFFFFFFF); // Pure White

  // Additional Colors
  static const cardBorder = Color(0xFF3F3F46); // Dark Border
  static const divider = Color(0xFF3F3F46); // Dark Divider
  static const inputFill = Color(0xFF2A2A30); // Input Background
  static const border = Color(0xFFE0E0E0); // Light gray border color

  // New Accent Colors
  static const accent1 = Color(0xFFFF79C6); // Neon Pink
  static const accent2 = Color(0xFF9B59B6); // Deep Purple
  static const accent3 = Color(0xFF0ABDE3); // Electric Blue
  static const accent4 = Color(0xFF00B894); // Mint

  static const Color success = Color(0xFF4CAF50); // Green color for success
  static const Color warning = Color(0xFFFFC107); // Amber color for warning
}

ThemeData appTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),

    // Typography
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    // Component Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.inputFill,
      selectedColor: AppColors.primary.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
