import '../../repositories/payment_history_repository.dart';
import '../../entities/payment_history_entity.dart';

class GetCustomerPayments {
  final PaymentHistoryRepository repository;

  GetCustomerPayments(this.repository);

  Future<List<PaymentHistoryEntity>> call(String customerId) async {
    return await repository.getCustomerPayments(customerId);
  }
}
