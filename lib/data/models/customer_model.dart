import 'package:hive/hive.dart';
import '../../domain/entities/customer_entity.dart';

part 'customer_model.g.dart';

/// Customer Model for Hive storage
/// Includes JSON serialization and Hive adapter
@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? phone;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final double totalBilled;

  @HiveField(6)
  final double totalPaid;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  CustomerModel({
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

  /// Convert from Entity to Model
  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      email: entity.email,
      totalBilled: entity.totalBilled,
      totalPaid: entity.totalPaid,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Model to Entity
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      phone: phone,
      address: address,
      email: email,
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'totalBilled': totalBilled,
      'totalPaid': totalPaid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      totalBilled: (json['totalBilled'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  CustomerModel copyWith({
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
    return CustomerModel(
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
}
