import 'package:hive/hive.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/payment_history_entity.dart';
import '../../domain/repositories/payment_history_repository.dart';
import '../models/payment_history_model.dart';

class PaymentHistoryRepositoryImpl implements PaymentHistoryRepository {
  Box<PaymentHistoryModel> _getBox() {
    return Hive.box<PaymentHistoryModel>(HiveBoxNames.paymentHistory);
  }

  @override
  Future<void> addPayment(PaymentHistoryEntity payment) async {
    final box = _getBox();
    final model = PaymentHistoryModel.fromEntity(payment);
    await box.put(payment.id, model);
  }

  @override
  Future<PaymentHistoryEntity?> getPaymentById(String paymentId) async {
    final box = _getBox();
    final model = box.get(paymentId);
    return model?.toEntity();
  }

  @override
  Future<void> updatePayment(PaymentHistoryEntity payment) async {
    final box = _getBox();
    final model = PaymentHistoryModel.fromEntity(payment);
    await box.put(payment.id, model);
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    final box = _getBox();
    await box.delete(paymentId);
  }

  @override
  Future<List<PaymentHistoryEntity>> getAllPayments() async {
    final box = _getBox();
    return box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<PaymentHistoryEntity>> getPaymentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final box = _getBox();
    return box.values
        .where((payment) =>
            payment.paymentDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            payment.paymentDate.isBefore(endDate.add(const Duration(seconds: 1))))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<PaymentHistoryEntity>> getPaymentsByInvoiceId(String invoiceId) async {
    final box = _getBox();
    final allPayments = box.values.map((model) => model.toEntity()).toList();
    
    // Filter by invoiceId
    final matchedPayments = allPayments.where((p) => p.invoiceId == invoiceId).toList();
    
    // Sort by date (newest first)
    matchedPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    
    return matchedPayments;
  }
}
