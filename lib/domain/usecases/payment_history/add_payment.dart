import '../../repositories/payment_history_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../entities/payment_history_entity.dart';

class AddPayment {
  final PaymentHistoryRepository paymentRepository;
  final CustomerRepository customerRepository;

  AddPayment({
    required this.paymentRepository,
    required this.customerRepository,
  });

  Future<void> call(PaymentHistoryEntity payment) async {
    // 1. Save the payment record
    await paymentRepository.addPayment(payment);

    // 2. Update customer's total paid amount
    final customer = await customerRepository.getCustomerById(payment.customerId);
    if (customer != null) {
      final updatedCustomer = customer.copyWith(
        totalPaid: customer.totalPaid + payment.paidAmount,
        updatedAt: DateTime.now(),
      );
      await customerRepository.updateCustomer(updatedCustomer);
    }
  }
}
