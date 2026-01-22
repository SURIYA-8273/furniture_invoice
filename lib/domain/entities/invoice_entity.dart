import 'invoice_item_entity.dart';

/// Invoice Entity
/// Represents a complete invoice with items and calculations.
class InvoiceEntity {
  final String id;
  final String invoiceNumber; // INV-000001
  final String customerId;
  final String customerName; // Denormalized for quick access
  final List<InvoiceItemEntity> items;
  final double subtotal; // Sum of all item amounts
  final double discount; // Discount amount
  final double gst; // GST amount
  final double grandTotal; // subtotal - discount + gst
  final double paidAmount; // Amount paid
  final double balanceAmount; // grandTotal - paidAmount
  final String status; // draft, pending, paid, partially_paid, cancelled
  final DateTime invoiceDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.gst = 0.0,
    required this.grandTotal,
    this.paidAmount = 0.0,
    required this.balanceAmount,
    required this.status,
    required this.invoiceDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate subtotal from items
  static double calculateSubtotal(List<InvoiceItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  /// Calculate grand total
  static double calculateGrandTotal(double subtotal, double discount, double gst) {
    return subtotal - discount + gst;
  }

  /// Calculate balance amount
  static double calculateBalanceAmount(double grandTotal, double paidAmount) {
    return grandTotal - paidAmount;
  }

  /// Determine invoice status based on payment
  static String determineStatus(double grandTotal, double paidAmount) {
    if (paidAmount <= 0) return 'pending';
    if (paidAmount >= grandTotal) return 'paid';
    return 'partially_paid';
  }

  /// Check if invoice is fully paid
  bool get isFullyPaid => balanceAmount <= 0;

  /// Check if invoice has pending balance
  bool get hasPendingBalance => balanceAmount > 0;

  /// Create a copy with updated fields
  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    List<InvoiceItemEntity>? items,
    double? subtotal,
    double? discount,
    double? gst,
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
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      gst: gst ?? this.gst,
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
    return 'InvoiceEntity(number: $invoiceNumber, customer: $customerName, total: ${grandTotal.toStringAsFixed(2)}, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceEntity &&
        other.id == id &&
        other.invoiceNumber == invoiceNumber &&
        other.customerId == customerId &&
        other.grandTotal == grandTotal &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        invoiceNumber.hashCode ^
        customerId.hashCode ^
        grandTotal.hashCode ^
        status.hashCode;
  }
}
