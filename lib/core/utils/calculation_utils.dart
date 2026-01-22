/// Calculation utility functions for billing.
class CalculationUtils {
  CalculationUtils._();

  /// Round to 2 decimal places
  static double roundTo2Decimals(double value) {
    return (value * 100).round() / 100;
  }

  /// Calculate percentage
  static double calculatePercentage(double value, double percentage) {
    return roundTo2Decimals(value * (percentage / 100));
  }

  /// Calculate GST amount
  static double calculateGst(double amount, double gstPercentage) {
    return calculatePercentage(amount, gstPercentage);
  }

  /// Calculate discount amount
  static double calculateDiscount(double amount, double discountPercentage) {
    return calculatePercentage(amount, discountPercentage);
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Parse currency string to double
  static double parseCurrency(String currencyString) {
    final cleaned = currencyString.replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Validate amount (must be non-negative)
  static bool isValidAmount(double amount) {
    return amount >= 0;
  }

  /// Calculate square feet from dimensions
  static double calculateSquareFeet(double width, double height) {
    return roundTo2Decimals(width * height);
  }
}
