// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   static const String _themeKey = 'theme_mode';
//   bool _isDarkMode = true; // Default to dark theme

//   ThemeProvider() {
//     _loadThemeFromPrefs();
//   }

//   bool get isDarkMode => _isDarkMode;

//   Future<void> _loadThemeFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool(_themeKey) ?? true;
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     _isDarkMode = !_isDarkMode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_themeKey, _isDarkMode);
//     notifyListeners();
//   }
// } 