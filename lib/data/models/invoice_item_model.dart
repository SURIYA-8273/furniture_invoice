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
  final double length;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double totalLength;

  @HiveField(6)
  final double rate;

  @HiveField(7)
  final double totalAmount;

  @HiveField(8)
  final String? typeIndex; // measurement, direct

  InvoiceItemModel({
    required this.id,
    required this.productName,
    required this.size,
    required this.length,
    required this.quantity,
    required this.totalLength,
    required this.rate,
    required this.totalAmount,
    this.typeIndex,
  });

  factory InvoiceItemModel.fromEntity(InvoiceItemEntity entity) {
    return InvoiceItemModel(
      id: entity.id,
      productName: entity.productName,
      size: entity.size,
      length: entity.length,
      quantity: entity.quantity,
      totalLength: entity.totalLength,
      rate: entity.rate,
      totalAmount: entity.totalAmount,
      typeIndex: entity.type.name,
    );
  }

  InvoiceItemEntity toEntity() {
    return InvoiceItemEntity(
      id: id,
      productName: productName,
      size: size,
      length: length,
      quantity: quantity,
      totalLength: totalLength,
      rate: rate,
      totalAmount: totalAmount,
      type: InvoiceItemType.values.firstWhere(
        (e) => e.name == (typeIndex ?? 'measurement'),
        orElse: () => InvoiceItemType.measurement,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'size': size,
      'length': length,
      'quantity': quantity,
      'totalLength': totalLength,
      'rate': rate,
      'totalAmount': totalAmount,
      'type': typeIndex,
    };
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      size: json['size'] as String,
      length: (json['length'] as num).toDouble(),
      quantity: json['quantity'] as int,
      totalLength: (json['totalLength'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      typeIndex: json['type'] as String? ?? 'measurement',
    );
  }
}
