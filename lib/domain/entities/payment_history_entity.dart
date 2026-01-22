/// Payment History Entity
/// Represents a single payment transaction made by a customer
class PaymentHistoryEntity {
  final String id;
  final String customerId;
  final DateTime paymentDate;
  final double paidAmount;
  final String paymentMode; // Cash, UPI, Bank Transfer, Card
  final double previousDue;
  final double remainingDue;
  final String? notes;
  final DateTime createdAt;

  PaymentHistoryEntity({
    required this.id,
    required this.customerId,
    required this.paymentDate,
    required this.paidAmount,
    required this.paymentMode,
    required this.previousDue,
    required this.remainingDue,
    required this.createdAt,
    this.notes,
  });

  /// Validate payment amount
  bool get isValidPayment => paidAmount > 0 && paidAmount <= previousDue;

  /// Check if this payment cleared the due
  bool get clearedDue => remainingDue == 0;

  /// Check if this was a partial payment
  bool get isPartialPayment => remainingDue > 0;

  /// Check if this was a full payment
  bool get isFullPayment => remainingDue == 0;

  /// Create a copy with updated fields
  PaymentHistoryEntity copyWith({
    String? id,
    String? customerId,
    DateTime? paymentDate,
    double? paidAmount,
    String? paymentMode,
    double? previousDue,
    double? remainingDue,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentHistoryEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      paymentDate: paymentDate ?? this.paymentDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      previousDue: previousDue ?? this.previousDue,
      remainingDue: remainingDue ?? this.remainingDue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PaymentHistoryEntity(id: $id, customerId: $customerId, paidAmount: $paidAmount, remainingDue: $remainingDue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentHistoryEntity &&
        other.id == id &&
        other.customerId == customerId &&
        other.paymentDate == paymentDate &&
        other.paidAmount == paidAmount &&
        other.paymentMode == paymentMode &&
        other.previousDue == previousDue &&
        other.remainingDue == remainingDue &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerId.hashCode ^
        paymentDate.hashCode ^
        paidAmount.hashCode ^
        paymentMode.hashCode ^
        previousDue.hashCode ^
        remainingDue.hashCode ^
        notes.hashCode;
  }
}
