import 'package:hive/hive.dart';
import '../../domain/entities/invoice_item_entity.dart';

part 'invoice_item_model.g.dart';

@HiveType(typeId: 5)
class InvoiceItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String size;

  @HiveField(3)
  final double squareFeet;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double totalQuantity;

  @HiveField(6)
  final double mrp;

  @HiveField(7)
  final double totalAmount;

  InvoiceItemModel({
    required this.id,
    required this.productName,
    required this.size,
    required this.squareFeet,
    required this.quantity,
    required this.totalQuantity,
    required this.mrp,
    required this.totalAmount,
  });

  factory InvoiceItemModel.fromEntity(InvoiceItemEntity entity) {
    return InvoiceItemModel(
      id: entity.id,
      productName: entity.productName,
      size: entity.size,
      squareFeet: entity.squareFeet,
      quantity: entity.quantity,
      totalQuantity: entity.totalQuantity,
      mrp: entity.mrp,
      totalAmount: entity.totalAmount,
    );
  }

  InvoiceItemEntity toEntity() {
    return InvoiceItemEntity(
      id: id,
      productName: productName,
      size: size,
      squareFeet: squareFeet,
      quantity: quantity,
      totalQuantity: totalQuantity,
      mrp: mrp,
      totalAmount: totalAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'size': size,
      'squareFeet': squareFeet,
      'quantity': quantity,
      'totalQuantity': totalQuantity,
      'mrp': mrp,
      'totalAmount': totalAmount,
    };
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      size: json['size'] as String,
      squareFeet: (json['squareFeet'] as num).toDouble(),
      quantity: json['quantity'] as int,
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}
