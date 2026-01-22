import 'package:flutter/material.dart';
import 'theme_tokens.dart';

/// Dark theme configuration for the billing application.
/// Uses centralized ThemeTokens for all design values.
class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: ThemeTokens.primaryColorLight,
        onPrimary: ThemeTokens.darkTextPrimary,
        primaryContainer: ThemeTokens.primaryColorDark,
        onPrimaryContainer: ThemeTokens.darkTextPrimary,
        
        secondary: ThemeTokens.secondaryColorLight,
        onSecondary: ThemeTokens.darkTextPrimary,
        secondaryContainer: ThemeTokens.secondaryColorDark,
        onSecondaryContainer: ThemeTokens.darkTextPrimary,
        
        error: ThemeTokens.errorColor,
        onError: Colors.white,
        
        surface: ThemeTokens.darkSurface,
        onSurface: ThemeTokens.darkTextPrimary,
        
        surfaceContainerHighest: ThemeTokens.darkCard,
        
        outline: ThemeTokens.darkBorder,
        outlineVariant: ThemeTokens.darkDivider,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: ThemeTokens.darkBackground,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeTokens.darkSurface,
        foregroundColor: ThemeTokens.darkTextPrimary,
        elevation: ThemeTokens.elevationLow,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleLarge,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: ThemeTokens.darkCard,
        elevation: ThemeTokens.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        ),
        margin: EdgeInsets.all(ThemeTokens.spacingSm),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primaryColorLight,
          foregroundColor: ThemeTokens.darkTextPrimary,
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
          foregroundColor: ThemeTokens.primaryColorLight,
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
          foregroundColor: ThemeTokens.primaryColorLight,
          side: BorderSide(color: ThemeTokens.primaryColorLight, width: 1.5),
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
        fillColor: ThemeTokens.darkCard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ThemeTokens.spacingMd,
          vertical: ThemeTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.darkBorder,
            width: ThemeTokens.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.darkBorder,
            width: ThemeTokens.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          borderSide: BorderSide(
            color: ThemeTokens.primaryColorLight,
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
          color: ThemeTokens.darkTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        hintStyle: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyMedium,
          color: ThemeTokens.darkTextHint,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemeTokens.primaryColorLight,
        foregroundColor: ThemeTokens.darkTextPrimary,
        elevation: ThemeTokens.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: ThemeTokens.darkDivider,
        thickness: 1.0,
        space: ThemeTokens.spacingMd,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: ThemeTokens.darkTextPrimary,
        size: ThemeTokens.iconSizeMedium,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplayLarge,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplayMedium,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: ThemeTokens.fontSizeDisplaySmall,
          fontWeight: ThemeTokens.fontWeightBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingLarge,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingMedium,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeHeadingSmall,
          fontWeight: ThemeTokens.fontWeightSemiBold,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleLarge,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleMedium,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeTitleSmall,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyLarge,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeBodyMedium,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: ThemeTokens.fontSizeBodySmall,
          fontWeight: ThemeTokens.fontWeightRegular,
          color: ThemeTokens.darkTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelLarge,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextPrimary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelMedium,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: ThemeTokens.fontSizeLabelSmall,
          fontWeight: ThemeTokens.fontWeightMedium,
          color: ThemeTokens.darkTextSecondary,
          fontFamily: ThemeTokens.fontFamily,
        ),
      ),
      
      // Font Family
      fontFamily: ThemeTokens.fontFamily,
    );
  }
}
