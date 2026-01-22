import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Main theme configuration export file.
/// Import this file to access all theme-related functionality.
class AppTheme {
  AppTheme._();
  
  /// Get light theme
  static ThemeData get lightTheme => LightTheme.theme;
  
  /// Get dark theme
  static ThemeData get darkTheme => DarkTheme.theme;
}
