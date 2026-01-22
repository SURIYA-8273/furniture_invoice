/// Customer Entity
/// Represents a customer with balance tracking capabilities.
class CustomerEntity {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final double totalBilled; // Total amount billed to customer
  final double totalPaid; // Total amount paid by customer
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    this.totalBilled = 0.0,
    this.totalPaid = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate outstanding balance
  double get outstandingBalance => totalBilled - totalPaid;
  
  /// Current due amount (alias for outstandingBalance for clarity)
  double get currentDue => outstandingBalance;

  /// Check if customer has pending dues
  bool get hasPendingDues => outstandingBalance > 0;
  
  /// Check if due is cleared
  bool get isDueCleared => outstandingBalance == 0;

  /// Check if customer has overpaid
  bool get hasOverpayment => outstandingBalance < 0;

  /// Create a copy with updated fields
  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    double? totalBilled,
    double? totalPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      totalBilled: totalBilled ?? this.totalBilled,
      totalPaid: totalPaid ?? this.totalPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CustomerEntity(id: $id, name: $name, phone: $phone, balance: ${outstandingBalance.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerEntity &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.address == address &&
        other.email == email &&
        other.totalBilled == totalBilled &&
        other.totalPaid == totalPaid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        email.hashCode ^
        totalBilled.hashCode ^
        totalPaid.hashCode;
  }
}
