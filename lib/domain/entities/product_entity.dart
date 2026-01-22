/// Product Entity
/// Represents a product/item that can be sold.
class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final double mrp; // Maximum Retail Price
  final String? size; // 3×5, 4×6, custom, etc.
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.mrp,
    this.size,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? mrp,
    String? size,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mrp: mrp ?? this.mrp,
      size: size ?? this.size,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, mrp: ${mrp.toStringAsFixed(2)}, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.mrp == mrp &&
        other.size == size &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        mrp.hashCode ^
        size.hashCode ^
        category.hashCode;
  }
}
