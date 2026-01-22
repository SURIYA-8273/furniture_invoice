/// Invoice Item Entity
/// Represents a single line item in an invoice.
/// Supports fully editable calculations.
class InvoiceItemEntity {
  final String id;
  final String productName;
  final String size; // 3×5, 4×6, custom
  final double squareFeet; // Can be auto-calculated OR manually entered
  final int quantity;
  final double totalQuantity; // squareFeet × quantity (can be overridden)
  final double mrp; // Price per unit (editable)
  final double totalAmount; // mrp × totalQuantity (can be overridden)

  InvoiceItemEntity({
    required this.id,
    required this.productName,
    required this.size,
    required this.squareFeet,
    required this.quantity,
    required this.totalQuantity,
    required this.mrp,
    required this.totalAmount,
  });

  /// Calculate square feet from size string (e.g., "3×5" = 15)
  static double calculateSquareFeetFromSize(String size) {
    try {
      final parts = size.split('×');
      if (parts.length == 2) {
        final width = double.tryParse(parts[0].trim());
        final height = double.tryParse(parts[1].trim());
        if (width != null && height != null) {
          return width * height;
        }
      }
    } catch (e) {
      // Return 0 if parsing fails
    }
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
    return 'InvoiceItemEntity(product: $productName, size: $size, qty: $quantity, amount: ${totalAmount.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceItemEntity &&
        other.id == id &&
        other.productName == productName &&
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
        size.hashCode ^
        squareFeet.hashCode ^
        quantity.hashCode ^
        totalQuantity.hashCode ^
        mrp.hashCode ^
        totalAmount.hashCode;
  }
}
