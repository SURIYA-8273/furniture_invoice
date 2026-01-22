import '../entities/payment_history_entity.dart';

/// Repository interface for payment history operations
abstract class PaymentHistoryRepository {
  /// Add a new payment record
  Future<void> addPayment(PaymentHistoryEntity payment);

  /// Get all payments for a specific customer
  Future<List<PaymentHistoryEntity>> getCustomerPayments(String customerId);

  /// Get a specific payment by ID
  Future<PaymentHistoryEntity?> getPaymentById(String paymentId);

  /// Update an existing payment record
  Future<void> updatePayment(PaymentHistoryEntity payment);

  /// Delete a payment record
  Future<void> deletePayment(String paymentId);

  /// Get all payments (for admin/reports)
  Future<List<PaymentHistoryEntity>> getAllPayments();

  /// Get payments within a date range
  Future<List<PaymentHistoryEntity>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
