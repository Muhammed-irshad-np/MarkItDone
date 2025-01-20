import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const darkprimary = Color(0xFF6C5CE7); // Modern Purple
  static const darksecondary = Color(0xFF00D2D3); // Bright Cyan
  static const darkbackground = Color(0xFF1A1B1E); // Dark Background
  static const darksurface = Color(0xFF2D2D34); // Card Background
  static const error = Color(0xFFFF6B6B); // Soft Red

  static const lightprimary = Color(0xFF1F696D); // Modern Purple
  static const lightbackground = Color(0xFFFFFFFF); // Light Background
  // Task Status Colors
  static const pending = Color(0xFFFFA502); // Warm Orange
  static const inProgress = Color(0xFF45AAF2); // Bright Blue
  static const completed = Color(0xFF2ECC71); // Fresh Green
  static const postponed = Color(0xFFFF7675); // Coral Red

  // Text Colors
  static const darktextPrimary = Color(0xFFF5F6FA); // Almost White
  static const darktextSecondary = Color(0xFFA4A5A7); // Muted Gray
  static const textDark = Color(0xFFFFFFFF); // Pure White

  static const lighttextPrimary = Color(0xFF000000); // Pure Black
  static const lighttextSecondary = Color(0xFF323232); // Muted Gray
  static const lightshadow = Color(0xFFC3D7E778); // Light gray shadow color
  static const textLight = Color(0xFFFFFFFF); // Modern Purple

  // Additional Colors
  static const cardBorder = Color(0xFF3F3F46); // Dark Border
  static const darkdivider = Color(0xFF3F3F46); // Dark Divider
  static const inputFill = Color(0xFF2A2A30); // Input Background
  static const border = Color(0xFFE0E0E0); // Light gray border color

  static const lightdivider = Color(0xFFEEF4F9); // Light Divider

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
    primaryColor: AppColors.darkprimary,
    scaffoldBackgroundColor: AppColors.darkbackground,
    hintColor: AppColors.darktextSecondary,
    cardColor: AppColors.cardBorder,
    shadowColor: AppColors.darkprimary.withOpacity(0.05),
    dividerColor: AppColors.darkdivider,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkprimary,
      secondary: AppColors.darksecondary,
      error: AppColors.error,
      background: AppColors.darkbackground,
      surface: AppColors.darksurface,
      onPrimary: AppColors.textDark,
      onSecondary: AppColors.textDark,
      onBackground: AppColors.darktextPrimary,
      onSurface: AppColors.darktextPrimary,
    ),

    // Typography
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darktextPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.darktextPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darktextPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darktextPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.darktextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.darktextSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darktextPrimary,
      ),
    ),

    // Component Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkprimary,
        foregroundColor: AppColors.textDark,
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
        borderSide: const BorderSide(color: AppColors.darkprimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.darktextSecondary,
      ),
    ),

    // Cards
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      color: AppColors.darksurface,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkprimary,
      foregroundColor: AppColors.textDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.inputFill,
      selectedColor: AppColors.darkprimary.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.darktextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

ThemeData lightTheme() {
  return ThemeData.light().copyWith(
    primaryColor: AppColors.lightprimary,
    scaffoldBackgroundColor: AppColors.lightbackground,
    shadowColor: AppColors.lightshadow,
    cardColor: AppColors.lightbackground,
    hintColor: AppColors.lighttextSecondary,
    dividerColor: AppColors.lightdivider,
    //
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkprimary,
      secondary: AppColors.darksecondary,
      error: AppColors.error,
      background: AppColors.darkbackground,
      surface: AppColors.lightbackground,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onBackground: AppColors.lighttextPrimary,
      onSurface: AppColors.lighttextPrimary,
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lighttextPrimary,
      ),
       headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.lighttextPrimary,
        letterSpacing: -0.5,
      ),
          headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.lighttextPrimary,
        letterSpacing: -0.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.lighttextPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.lighttextSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lighttextPrimary,
      ),
    ),
  );
}
