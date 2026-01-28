import 'invoice_item_entity.dart';

/// Invoice Entity
/// Represents a complete invoice with items and calculations.
class InvoiceEntity {
  final String id;
  final String invoiceNumber; // INV-000001
  final String? customerName;
  final List<InvoiceItemEntity> items;
  final double grandTotal; // Sum of all item amounts
  final double paidAmount; // Amount paid
  final double balanceAmount; // grandTotal - paidAmount
  final String status; // unpaid, partial, paid, cancelled
  final DateTime invoiceDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
    required this.items,
    required this.grandTotal,
    this.paidAmount = 0.0,
    required this.balanceAmount,
    required this.status,
    required this.invoiceDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate grand total from items
  static double calculateGrandTotal(List<InvoiceItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  /// Calculate balance amount
  static double calculateBalanceAmount(double grandTotal, double paidAmount) {
    return grandTotal - paidAmount;
  }

  /// Determine invoice status based on payment
  static String determineStatus(double grandTotal, double paidAmount) {
    if (paidAmount <= 0) return 'unpaid';
    if (paidAmount >= grandTotal) return 'paid';
    return 'partial';
  }

  /// Check if invoice is fully paid
  bool get isFullyPaid => balanceAmount <= 0;

  /// Check if invoice has pending balance
  bool get hasPendingBalance => balanceAmount > 0;

  /// Create a copy with updated fields
  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerName,
    List<InvoiceItemEntity>? items,
    double? grandTotal,
    double? paidAmount,
    double? balanceAmount,
    String? status,
    DateTime? invoiceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      status: status ?? this.status,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'InvoiceEntity(number: $invoiceNumber, total: ${grandTotal.toStringAsFixed(2)}, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceEntity &&
        other.id == id &&
        other.invoiceNumber == invoiceNumber &&
        other.grandTotal == grandTotal &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        invoiceNumber.hashCode ^
        grandTotal.hashCode ^
        status.hashCode;
  }
}
