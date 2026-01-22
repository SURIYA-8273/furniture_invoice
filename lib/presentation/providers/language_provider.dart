import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Language provider for managing app language state with Hive persistence.
/// Supports Tamil and English with auto-detection and manual switching.
class LanguageProvider extends ChangeNotifier {
  static const String _languageBoxName = 'language_settings';
  static const String _languageCodeKey = 'language_code';
  
  late Box _languageBox;
  Locale _currentLocale = const Locale(AppConstants.languageEnglish);
  
  /// Current locale
  Locale get currentLocale => _currentLocale;
  
  /// Current language code
  String get languageCode => _currentLocale.languageCode;
  
  /// Check if current language is Tamil
  bool get isTamil => _currentLocale.languageCode == AppConstants.languageTamil;
  
  /// Check if current language is English
  bool get isEnglish => _currentLocale.languageCode == AppConstants.languageEnglish;
  
  /// Supported locales
  List<Locale> get supportedLocales => const [
        Locale(AppConstants.languageEnglish),
        Locale(AppConstants.languageTamil),
      ];
  
  /// Initialize language provider and load saved language preference
  Future<void> initialize() async {
    try {
      // Open Hive box for language settings
      _languageBox = await Hive.openBox(_languageBoxName);
      
      // Load saved language code
      final savedLanguageCode = _languageBox.get(
        _languageCodeKey,
        defaultValue: AppConstants.languageEnglish,
      );
      
      _currentLocale = Locale(savedLanguageCode);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing language provider: $e');
      // Default to English if there's an error
      _currentLocale = const Locale(AppConstants.languageEnglish);
    }
  }
  
  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    
    // Validate language code
    if (languageCode != AppConstants.languageEnglish &&
        languageCode != AppConstants.languageTamil) {
      debugPrint('Unsupported language code: $languageCode');
      return;
    }
    
    _currentLocale = Locale(languageCode);
    
    // Save to Hive
    try {
      await _languageBox.put(_languageCodeKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
    
    notifyListeners();
  }
  
  /// Set English language
  Future<void> setEnglish() async {
    await changeLanguage(AppConstants.languageEnglish);
  }
  
  /// Set Tamil language
  Future<void> setTamil() async {
    await changeLanguage(AppConstants.languageTamil);
  }
  
  /// Toggle between English and Tamil
  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await setTamil();
    } else {
      await setEnglish();
    }
  }
  
  /// Get locale from language code
  Locale getLocaleFromLanguageCode(String languageCode) {
    return Locale(languageCode);
  }
  
  @override
  void dispose() {
    _languageBox.close();
    super.dispose();
  }
}
