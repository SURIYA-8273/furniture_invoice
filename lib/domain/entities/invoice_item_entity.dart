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
  final double length; // Can be auto-calculated OR manually entered (Only for measurement)
  final int quantity; // Pieces (Only for measurement)
  final double totalLength; // length × quantity OR direct entry
  final double rate; // Price per unit (editable)
  final double totalAmount; // rate × totalLength (can be overridden)

  InvoiceItemEntity({
    required this.id,
    required this.productName,
    this.type = InvoiceItemType.measurement, // Default
    this.size = '',
    this.length = 0.0,
    this.quantity = 1,
    required this.totalLength,
    required this.rate,
    required this.totalAmount,
  });

  /// Calculate length from size string (e.g., "3×5" = 15)
  /// Deprecated: Size no longer determines calculations
  static double calculateLengthFromSize(String size) {
    return 0.0;
  }

  /// Auto-calculate total length
  static double calculateTotalLength(double length, int quantity) {
    return length * quantity;
  }

  /// Auto-calculate total amount
  static double calculateTotalAmount(double rate, double totalLength) {
    return rate * totalLength;
  }

  /// Create a copy with updated fields
  InvoiceItemEntity copyWith({
    String? id,
    String? productName,
    InvoiceItemType? type,
    String? size,
    double? length,
    int? quantity,
    double? totalLength,
    double? rate,
    double? totalAmount,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      size: size ?? this.size,
      length: length ?? this.length,
      quantity: quantity ?? this.quantity,
      totalLength: totalLength ?? this.totalLength,
      rate: rate ?? this.rate,
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
        other.length == length &&
        other.quantity == quantity &&
        other.totalLength == totalLength &&
        other.rate == rate &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productName.hashCode ^
        type.hashCode ^
        size.hashCode ^
        length.hashCode ^
        quantity.hashCode ^
        totalLength.hashCode ^
        rate.hashCode ^
        totalAmount.hashCode;
  }
}
