import '../../entities/payment_history_entity.dart';
import '../../repositories/payment_history_repository.dart';

class GetInvoicePayments {
  final PaymentHistoryRepository repository;

  GetInvoicePayments(this.repository);

  Future<List<PaymentHistoryEntity>> call(String invoiceId) async {
    return await repository.getPaymentsByInvoiceId(invoiceId);
  }
}
