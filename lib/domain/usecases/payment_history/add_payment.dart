import '../../repositories/payment_history_repository.dart';
import '../../entities/payment_history_entity.dart';

class AddPayment {
  final PaymentHistoryRepository paymentRepository;

  AddPayment({
    required this.paymentRepository,
  });

  Future<void> call(PaymentHistoryEntity payment) async {
    // 1. Save the payment record
    await paymentRepository.addPayment(payment);
  }
}
