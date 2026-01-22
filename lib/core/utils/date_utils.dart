import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date utility functions for the application.
class DateUtils {
  DateUtils._();

  /// Format date for display (dd/MM/yyyy)
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date and time for display (dd/MM/yyyy hh:mm a)
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }

  /// Format date for storage (yyyy-MM-dd)
  static String formatDateForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date and time for storage (yyyy-MM-dd HH:mm:ss)
  static String formatDateTimeForStorage(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// Parse date from storage format
  static DateTime parseDateFromStorage(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get date range for reports
  static DateTimeRange getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    final today = startOfDay(now);

    switch (period.toLowerCase()) {
      case 'today':
        return DateTimeRange(start: today, end: endOfDay(now));
      
      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: yesterday, end: endOfDay(yesterday));
      
      case 'this_week':
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: weekStart, end: endOfDay(now));
      
      case 'this_month':
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: endOfDay(now));
      
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: lastMonth, end: endOfDay(lastMonthEnd));
      
      default:
        return DateTimeRange(start: today, end: endOfDay(now));
    }
  }
}
