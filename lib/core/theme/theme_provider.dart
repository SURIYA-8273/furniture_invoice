import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Theme provider for managing app theme state with Hive persistence.
/// Supports light and dark themes with runtime switching.
class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';
  
  late Box _themeBox;
  ThemeMode _themeMode = ThemeMode.light;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Get light theme data
  ThemeData get lightTheme => LightTheme.theme;
  
  /// Get dark theme data
  ThemeData get darkTheme => DarkTheme.theme;
  
  /// Initialize theme provider and load saved theme preference
  Future<void> initialize() async {
    try {
      // Open Hive box for theme settings
      _themeBox = await Hive.openBox(_themeBoxName);
      
      // Load saved theme mode
      final savedThemeMode = _themeBox.get(_themeModeKey, defaultValue: 'light');
      _themeMode = _getThemeModeFromString(savedThemeMode);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme provider: $e');
      // Default to light theme if there's an error
      _themeMode = ThemeMode.light;
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
  
  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    // Save to Hive
    try {
      await _themeBox.put(_themeModeKey, _getStringFromThemeMode(mode));
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
    
    notifyListeners();
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setTheme(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setTheme(ThemeMode.dark);
  }
  
  /// Convert ThemeMode to string for storage
  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  /// Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
  
  @override
  void dispose() {
    _themeBox.close();
    super.dispose();
  }
}
