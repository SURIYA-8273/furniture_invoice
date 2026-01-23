import 'package:flutter/material.dart';
import '../../domain/entities/payment_history_entity.dart';
import '../../domain/usecases/payment_history/add_payment.dart';

class PaymentHistoryProvider extends ChangeNotifier {
  final AddPayment addPaymentUseCase;

  List<PaymentHistoryEntity> _payments = [];
  bool _isLoading = false;
  String? _error;

  PaymentHistoryProvider({
    required this.addPaymentUseCase,
  });

  List<PaymentHistoryEntity> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // No-op for removed loadPayments

  /// Record a new payment
  Future<bool> recordPayment(PaymentHistoryEntity payment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await addPaymentUseCase(payment);
      // Reload payments to reflect changes
      // await loadPayments(payment.customerId);
      return true;
    } catch (e) {
      _error = 'Failed to record payment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
