/// Payment Entity
/// Represents a payment transaction.
class PaymentEntity {
  final String id;
  final String customerId;
  final String? invoiceId; // Optional - can be general payment
  final double amount;
  final String paymentMode; // cash, card, upi, bank_transfer, cheque
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;

  PaymentEntity({
    required this.id,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  PaymentEntity copyWith({
    String? id,
    String? customerId,
    String? invoiceId,
    double? amount,
    String? paymentMode,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
