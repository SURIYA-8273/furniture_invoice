/// Invoice Item Type
enum InvoiceItemType {
  measurement, // Dimension based (WxH -> SqFt -> Total)
  direct,      // Direct Quantity (Total Qty -> Total)
}

/// Invoice Item Entity
/// Represents a single line item in an invoice.
/// Supports fully editable calculations.
class InvoiceItemEntity {
  final String id;
  final String productName;
  final InvoiceItemType type; // New field
  final String size; // 3×5, 4×6, custom (Only for measurement)
  final double squareFeet; // Can be auto-calculated OR manually entered (Only for measurement)
  final int quantity; // Pieces (Only for measurement)
  final double totalQuantity; // squareFeet × quantity OR direct entry
  final double mrp; // Price per unit (editable)
  final double totalAmount; // mrp × totalQuantity (can be overridden)

  InvoiceItemEntity({
    required this.id,
    required this.productName,
    this.type = InvoiceItemType.measurement, // Default
    this.size = '',
    this.squareFeet = 0.0,
    this.quantity = 1,
    required this.totalQuantity,
    required this.mrp,
    required this.totalAmount,
  });

  /// Calculate square feet from size string (e.g., "3×5" = 15)
  /// Deprecated: Size no longer determines calculations
  static double calculateSquareFeetFromSize(String size) {
    return 0.0;
  }

  /// Auto-calculate total quantity
  static double calculateTotalQuantity(double squareFeet, int quantity) {
    return squareFeet * quantity;
  }

  /// Auto-calculate total amount
  static double calculateTotalAmount(double mrp, double totalQuantity) {
    return mrp * totalQuantity;
  }

  /// Create a copy with updated fields
  InvoiceItemEntity copyWith({
    String? id,
    String? productName,
    InvoiceItemType? type,
    String? size,
    double? squareFeet,
    int? quantity,
    double? totalQuantity,
    double? mrp,
    double? totalAmount,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      size: size ?? this.size,
      squareFeet: squareFeet ?? this.squareFeet,
      quantity: quantity ?? this.quantity,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      mrp: mrp ?? this.mrp,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  String toString() {
    return 'InvoiceItemEntity(product: $productName, type: $type, size: $size, qty: $quantity, amount: ${totalAmount.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceItemEntity &&
        other.id == id &&
        other.productName == productName &&
        other.type == type &&
        other.size == size &&
        other.squareFeet == squareFeet &&
        other.quantity == quantity &&
        other.totalQuantity == totalQuantity &&
        other.mrp == mrp &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productName.hashCode ^
        type.hashCode ^
        size.hashCode ^
        squareFeet.hashCode ^
        quantity.hashCode ^
        totalQuantity.hashCode ^
        mrp.hashCode ^
        totalAmount.hashCode;
  }
}
