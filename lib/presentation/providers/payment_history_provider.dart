import 'package:flutter/material.dart';
import '../../domain/entities/payment_history_entity.dart';
import '../../domain/usecases/payment_history/add_payment.dart';
import '../../domain/usecases/payment_history/get_invoice_payments.dart';

class PaymentHistoryProvider extends ChangeNotifier {
  final AddPayment addPaymentUseCase;
  final GetInvoicePayments getInvoicePaymentsUseCase;

  List<PaymentHistoryEntity> _payments = [];
  bool _isLoading = false;
  String? _error;

  PaymentHistoryProvider({
    required this.addPaymentUseCase,
    required this.getInvoicePaymentsUseCase,
  });

  List<PaymentHistoryEntity> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load payments for a specific invoice
  Future<void> loadPayments(String invoiceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await getInvoicePaymentsUseCase(invoiceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load payments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record a new payment
  Future<bool> recordPayment(PaymentHistoryEntity payment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await addPaymentUseCase(payment);
      // Reload payments to reflect changes
      if (payment.invoiceId != null) {
        await loadPayments(payment.invoiceId!);
      }
      
      // Real-time backup trigger - DISABLED as per request (store local only)
      // BackupService.instance.syncPayment(payment);
      
      return true;
    } catch (e) {
      _error = 'Failed to record payment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
