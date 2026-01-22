/// Application-wide constants.
class AppConstants {
  AppConstants._();
  
  // App Information
  static const String appName = 'Furniture Billing';
  static const String appVersion = '1.0.0';
  
  // Supported Languages
  static const String languageEnglish = 'en';
  static const String languageTamil = 'ta';
  
  // Date Formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatStorage = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy hh:mm a';
  static const String dateTimeFormatStorage = 'yyyy-MM-dd HH:mm:ss';
  
  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  
  // Invoice Settings
  static const String invoicePrefix = 'INV';
  static const int invoiceNumberLength = 6;
  
  // Payment Modes
  static const String paymentModeCash = 'cash';
  static const String paymentModeCard = 'card';
  static const String paymentModeUpi = 'upi';
  static const String paymentModeBankTransfer = 'bank_transfer';
  static const String paymentModeCheque = 'cheque';
  
  // Invoice Status
  static const String invoiceStatusDraft = 'draft';
  static const String invoiceStatusPending = 'pending';
  static const String invoiceStatusPaid = 'paid';
  static const String invoiceStatusPartiallyPaid = 'partially_paid';
  static const String invoiceStatusCancelled = 'cancelled';
  
  // Product Sizes (Common furniture sizes)
  static const List<String> commonSizes = [
    '3×5',
    '4×6',
    '5×7',
    '6×8',
    '7×9',
    '8×10',
    'Custom',
  ];
  
  // Validation
  static const int minBusinessNameLength = 3;
  static const int maxBusinessNameLength = 100;
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 100;
  static const int minProductNameLength = 2;
  static const int maxProductNameLength = 100;
  
  // Phone Number Validation (Indian)
  static const String phoneNumberPattern = r'^[6-9]\d{9}$';
  
  // GST Number Validation
  static const String gstNumberPattern = r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$';
  
  // Email Validation
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // URL Validation
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // Backup Settings
  static const int autoBackupIntervalHours = 24;
  static const int maxBackupVersions = 5;
  
  // Sync Settings
  static const int syncIntervalMinutes = 30;
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;
  
  // PDF Settings
  static const String pdfFileNamePrefix = 'Invoice_';
  static const String pdfDateFormat = 'yyyyMMdd_HHmmss';
  
  // WhatsApp
  static const String whatsappScheme = 'whatsapp://send';
  static const String whatsappWebUrl = 'https://wa.me/';
}
