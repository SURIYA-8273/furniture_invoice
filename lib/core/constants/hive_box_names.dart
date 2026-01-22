/// Hive box names for the application.
/// Centralized constants for all Hive box identifiers.
class HiveBoxNames {
  HiveBoxNames._();
  
  // Settings
  static const String themeSettings = 'theme_settings';
  static const String languageSettings = 'language_settings';
  static const String appSettings = 'app_settings';
  
  // Business Data
  static const String businessProfile = 'business_profile';
  static const String customers = 'customers';
  static const String products = 'products';
  static const String invoices = 'invoices';
  static const String invoiceItems = 'invoice_items';
  static const String payments = 'payments';
  static const String paymentHistory = 'payment_history';
  static const String balanceHistory = 'balance_history';
}

/// Hive type IDs for adapters.
/// Each Hive model must have a unique type ID.
class HiveTypeIds {
  HiveTypeIds._();
  
  static const int businessProfile = 0;
  static const int customer = 1;
  static const int product = 2;
  static const int invoice = 3;
  static const int invoiceItem = 4;
  static const int payment = 5;
  static const int balanceHistory = 6;
}
