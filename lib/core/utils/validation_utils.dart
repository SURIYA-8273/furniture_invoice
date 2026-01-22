import '../../core/constants/app_constants.dart';

/// Validation utilities for the application.
class ValidationUtils {
  ValidationUtils._();

  /// Validate business name
  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business name is required';
    }

    if (value.trim().length < AppConstants.minBusinessNameLength) {
      return 'Business name must be at least ${AppConstants.minBusinessNameLength} characters';
    }

    if (value.trim().length > AppConstants.maxBusinessNameLength) {
      return 'Business name must not exceed ${AppConstants.maxBusinessNameLength} characters';
    }

    return null;
  }

  /// Validate phone number (Indian format)
  static String? validatePhoneNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    final phoneRegex = RegExp(AppConstants.phoneNumberPattern);
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number. Must be 10 digits starting with 6-9';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email address';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    final urlRegex = RegExp(AppConstants.urlPattern);
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Invalid URL. Must start with http:// or https://';
    }

    return null;
  }

  /// Validate GST number
  static String? validateGstNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'GST number is required' : null;
    }

    final gstRegex = RegExp(AppConstants.gstNumberPattern);
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Invalid GST number format';
    }

    return null;
  }

  /// Validate customer name
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer name is required';
    }

    if (value.trim().length < AppConstants.minCustomerNameLength) {
      return 'Customer name must be at least ${AppConstants.minCustomerNameLength} characters';
    }

    if (value.trim().length > AppConstants.maxCustomerNameLength) {
      return 'Customer name must not exceed ${AppConstants.maxCustomerNameLength} characters';
    }

    return null;
  }

  /// Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }

    if (value.trim().length < AppConstants.minProductNameLength) {
      return 'Product name must be at least ${AppConstants.minProductNameLength} characters';
    }

    if (value.trim().length > AppConstants.maxProductNameLength) {
      return 'Product name must not exceed ${AppConstants.maxProductNameLength} characters';
    }

    return null;
  }

  /// Validate amount (must be positive)
  static String? validateAmount(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Amount is required' : null;
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Invalid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  /// Validate quantity (must be positive integer)
  static String? validateQuantity(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Quantity is required' : null;
    }

    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Invalid quantity';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    return null;
  }

  /// Validate MRP (must be positive number)
  static String? validateMRP(double mrp) {
    if (mrp <= 0) {
      return 'MRP must be greater than 0';
    }

    return null;
  }
}
