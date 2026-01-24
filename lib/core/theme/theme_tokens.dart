import 'package:flutter/material.dart';

/// Centralized design tokens for the billing application.
/// ALL UI components must use these tokens instead of hardcoded values.
/// This ensures consistent theming and easy customization.
class ThemeTokens {
  // Private constructor to prevent instantiation
  ThemeTokens._();

  // ============================================================
  // BRAND COLORS
  // ============================================================
  
  /// Primary brand color - used for main actions and highlights
  static const Color primaryColor = Colors.blue; // 0xFF2196F3
  
  /// Primary color variant for hover/pressed states
  static const Color primaryColorDark = Color(0xFF1565C0);
  
  /// Primary color light variant
  static const Color primaryColorLight = Color(0xFF42A5F5);
  
  /// Secondary brand color - used for accents
  static const Color secondaryColor = Color(0xFFFF6F00); // Orange
  
  /// Secondary color dark variant
  static const Color secondaryColorDark = Color(0xFFE65100);
  
  /// Secondary color light variant
  static const Color secondaryColorLight = Color(0xFFFF8F00);

  // ============================================================
  // SEMANTIC COLORS
  // ============================================================
  
  /// Success color - for positive actions and confirmations
  static const Color successColor = Color(0xFF4CAF50); // Green
  
  /// Warning color - for caution and alerts
  static const Color warningColor = Color(0xFFFFA726); // Amber
  
  /// Error color - for errors and destructive actions
  static const Color errorColor = Color(0xFFE53935); // Red
  
  /// Info color - for informational messages
  static const Color infoColor = Color(0xFF29B6F6); // Light Blue

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================
  
  /// Light theme background color
  static const Color lightBackground = Color(0xFFF5F5F5);
  
  /// Light theme surface color (cards, dialogs)
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  /// Light theme card color
  static const Color lightCard = Color(0xFFFFFFFF);
  
  /// Light theme primary text color
  static const Color lightTextPrimary = Color(0xFF212121);
  
  /// Light theme secondary text color
  static const Color lightTextSecondary = Color(0xFF757575);
  
  /// Light theme disabled text color
  static const Color lightTextDisabled = Color(0xFFBDBDBD);
  
  /// Light theme hint text color
  static const Color lightTextHint = Color(0xFF9E9E9E);
  
  /// Light theme divider color
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  /// Light theme border color
  static const Color lightBorder = Color(0xFFE0E0E0);

  // ============================================================
  // DARK THEME COLORS
  // ============================================================
  
  /// Dark theme background color
  static const Color darkBackground = Color(0xFF121212);
  
  /// Dark theme surface color (cards, dialogs)
  static const Color darkSurface = Color(0xFF1E1E1E);
  
  /// Dark theme card color
  static const Color darkCard = Color(0xFF2C2C2C);
  
  /// Dark theme primary text color
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  
  /// Dark theme secondary text color
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  /// Dark theme disabled text color
  static const Color darkTextDisabled = Color(0xFF6E6E6E);
  
  /// Dark theme hint text color
  static const Color darkTextHint = Color(0xFF8E8E8E);
  
  /// Dark theme divider color
  static const Color darkDivider = Color(0xFF3E3E3E);
  
  /// Dark theme border color
  static const Color darkBorder = Color(0xFF3E3E3E);

  // ============================================================
  // SPACING TOKENS
  // ============================================================
  
  /// Extra small spacing - 4.0
  static const double spacingXs = 4.0;
  
  /// Small spacing - 8.0
  static const double spacingSm = 8.0;
  
  /// Medium spacing - 16.0
  static const double spacingMd = 16.0;
  
  /// Large spacing - 24.0
  static const double spacingLg = 24.0;
  
  /// Extra large spacing - 32.0
  static const double spacingXl = 32.0;
  
  /// Extra extra large spacing - 48.0
  static const double spacingXxl = 48.0;

  // ============================================================
  // BORDER RADIUS TOKENS
  // ============================================================
  
  /// Small border radius - 4.0
  static const double radiusSmall = 4.0;
  
  /// Medium border radius - 8.0
  static const double radiusMedium = 8.0;
  
  /// Large border radius - 12.0
  static const double radiusLarge = 12.0;
  
  /// Extra large border radius - 16.0
  static const double radiusXLarge = 16.0;
  
  /// Circular border radius - 999.0
  static const double radiusCircular = 999.0;

  // ============================================================
  // ELEVATION TOKENS
  // ============================================================
  
  /// Low elevation - 2.0
  static const double elevationLow = 2.0;
  
  /// Medium elevation - 4.0
  static const double elevationMedium = 4.0;
  
  /// High elevation - 8.0
  static const double elevationHigh = 8.0;
  
  /// Extra high elevation - 16.0
  static const double elevationXHigh = 16.0;

  // ============================================================
  // TYPOGRAPHY TOKENS
  // ============================================================
  
  /// Font family for the application
  static const String fontFamily = 'Roboto';
  
  /// Display large font size - 57.0
  static const double fontSizeDisplayLarge = 57.0;
  
  /// Display medium font size - 45.0
  static const double fontSizeDisplayMedium = 45.0;
  
  /// Display small font size - 36.0
  static const double fontSizeDisplaySmall = 36.0;
  
  /// Heading large font size - 32.0
  static const double fontSizeHeadingLarge = 32.0;
  
  /// Heading medium font size - 28.0
  static const double fontSizeHeadingMedium = 28.0;
  
  /// Heading small font size - 24.0
  static const double fontSizeHeadingSmall = 24.0;
  
  /// Title large font size - 22.0
  static const double fontSizeTitleLarge = 22.0;
  
  /// Title medium font size - 16.0
  static const double fontSizeTitleMedium = 16.0;
  
  /// Title small font size - 14.0
  static const double fontSizeTitleSmall = 14.0;
  
  /// Body large font size - 16.0
  static const double fontSizeBodyLarge = 16.0;
  
  /// Body medium font size - 14.0
  static const double fontSizeBodyMedium = 14.0;
  
  /// Body small font size - 12.0
  static const double fontSizeBodySmall = 12.0;
  
  /// Label large font size - 14.0
  static const double fontSizeLabelLarge = 14.0;
  
  /// Label medium font size - 12.0
  static const double fontSizeLabelMedium = 12.0;
  
  /// Label small font size - 11.0
  static const double fontSizeLabelSmall = 11.0;
  
  /// Amount highlight font size (for billing amounts) - 20.0
  static const double fontSizeAmountHighlight = 20.0;
  
  /// Font weight light - 300
  static const FontWeight fontWeightLight = FontWeight.w300;
  
  /// Font weight regular - 400
  static const FontWeight fontWeightRegular = FontWeight.w400;
  
  /// Font weight medium - 500
  static const FontWeight fontWeightMedium = FontWeight.w500;
  
  /// Font weight semi-bold - 600
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  
  /// Font weight bold - 700
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ============================================================
  // ICON SIZES
  // ============================================================
  
  /// Small icon size - 16.0
  static const double iconSizeSmall = 16.0;
  
  /// Medium icon size - 24.0
  static const double iconSizeMedium = 24.0;
  
  /// Large icon size - 32.0
  static const double iconSizeLarge = 32.0;
  
  /// Extra large icon size - 48.0
  static const double iconSizeXLarge = 48.0;

  // ============================================================
  // BUTTON SIZES
  // ============================================================
  
  /// Button height small - 36.0
  static const double buttonHeightSmall = 36.0;
  
  /// Button height medium - 48.0
  static const double buttonHeightMedium = 48.0;
  
  /// Button height large - 56.0
  static const double buttonHeightLarge = 56.0;
  
  /// Button minimum width - 88.0
  static const double buttonMinWidth = 88.0;

  // ============================================================
  // INPUT FIELD SIZES
  // ============================================================
  
  /// Input field height - 56.0
  static const double inputHeight = 56.0;
  
  /// Input field border width - 1.0
  static const double inputBorderWidth = 1.0;
  
  /// Input field focused border width - 2.0
  static const double inputFocusedBorderWidth = 2.0;
}
