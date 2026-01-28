import 'package:flutter/material.dart';
import 'theme_tokens.dart';

/// Light theme configuration for the billing application.
/// Uses centralized ThemeTokens for all design values.
class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: ThemeTokens.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: ThemeTokens.primaryColorLight,
        onPrimaryContainer: ThemeTokens.lightTextPrimary,
        
        secondary: ThemeTokens.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: ThemeTokens.secondaryColorLight,
        onSecondaryContainer: ThemeTokens.lightTextPrimary,
        
        error: ThemeTokens.errorColor,
        onError: Colors.white,
        
        surface: ThemeTokens.lightSurface,
        onSurface: ThemeTokens.lightTextPrimary,
        
        surfaceContainerHighest: ThemeTokens.lightCard,
        
        outline: ThemeTokens.lightBorder,
        outlineVariant: ThemeTokens.lightDivider,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: ThemeTokens.lightBackground,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeTokens.primaryColor,
        foregroundColor: Colors.white,
        elevation: ThemeTokens.elevationLow,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleLarge,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: Colors.white,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: ThemeTokens.lightCard,
        elevation: ThemeTokens.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        ),
        margin: EdgeInsets.all(ThemeTokens.spacingSm),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primaryColor,
          foregroundColor: Colors.white,
          elevation: ThemeTokens.elevationLow,
          padding: EdgeInsets.symmetric(
            horizontal: ThemeTokens.spacingLg,
            vertical: ThemeTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          ),
          minimumSize: Size(ThemeTokens.buttonMinWidth, ThemeTokens.buttonHeightMedium),
          textStyle: TextStyle(
            fontSize: ThemeTokens.fontSizeBodyLarge,
            fontWeight: ThemeTokens.fontWeightSemiBold,
            fontFamily: ThemeTokens.fontFamily,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeTokens.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: ThemeTokens.spacingMd,
            vertical: ThemeTokens.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          ),
          textStyle: TextStyle(
            fontSize: ThemeTokens.fontSizeBodyMedium,
            fontWeight: ThemeTokens.fontWeightMedium,
            fontFamily: ThemeTokens.fontFamily,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeTokens.primaryColor,
          side: BorderSide(color: ThemeTokens.primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: ThemeTokens.spacingLg,
            vertical: ThemeTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          ),
          minimumSize: Size(ThemeTokens.buttonMinWidth, ThemeTokens.buttonHeightMedium),
          textStyle: TextStyle(
            fontSize: ThemeTokens.fontSizeBodyLarge,
            fontWeight: ThemeTokens.fontWeightSemiBold,
            fontFamily: ThemeTokens.fontFamily,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeTokens.lightSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ThemeTokens.spacingMd,
          vertical: ThemeTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.lightBorder,
            width: ThemeTokens.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.lightBorder,
            width: ThemeTokens.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.primaryColor,
            width: ThemeTokens.inputFocusedBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.errorColor,
            width: ThemeTokens.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.errorColor,
            width: ThemeTokens.inputFocusedBorderWidth,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyMedium,
          color: ThemeTokens.lightTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        hintStyle: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyMedium,
          color: ThemeTokens.lightTextHint,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemeTokens.primaryColor,
        foregroundColor: Colors.white,
        elevation: ThemeTokens.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[900],
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: ThemeTokens.lightDivider,
        thickness: 1.0,
        space: ThemeTokens.spacingMd,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: ThemeTokens.lightTextPrimary,
        size: ThemeTokens.iconSizeMedium,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplayLarge,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplayMedium,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplaySmall,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingLarge,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingMedium,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingSmall,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleLarge,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleMedium,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleSmall,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyLarge,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyMedium,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: ThemeTokens.fontSizeBodySmall,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.lightTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelLarge,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelMedium,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelSmall,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.lightTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Font Family
      fontFamily: ThemeTokens.fontFamily,
    );
  }
}
