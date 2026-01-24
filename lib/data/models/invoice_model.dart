import 'package:hive/hive.dart';
import '../../domain/entities/invoice_entity.dart';
import 'invoice_item_model.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 4)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(13)
  final String? customerName;

  @HiveField(2)
  final List<InvoiceItemModel> items;

  @HiveField(3)
  final double subtotal;

  @HiveField(4)
  final double discount;

  @HiveField(5)
  final double gst;

  @HiveField(6)
  final double grandTotal;

  @HiveField(7)
  final double paidAmount;

  @HiveField(8)
  final double balanceAmount;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime invoiceDate;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
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

  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      customerName: entity.customerName,
      items: entity.items.map((e) => InvoiceItemModel.fromEntity(e)).toList(),
      subtotal: entity.subtotal,
      discount: entity.discount,
      gst: entity.gst,
      grandTotal: entity.grandTotal,
      paidAmount: entity.paidAmount,
      balanceAmount: entity.balanceAmount,
      status: entity.status,
      invoiceDate: entity.invoiceDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      customerName: customerName,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      discount: discount,
      gst: gst,
      grandTotal: grandTotal,
      paidAmount: paidAmount,
      balanceAmount: balanceAmount,
      status: status,
      invoiceDate: invoiceDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'gst': gst,
      'grandTotal': grandTotal,
      'paidAmount': paidAmount,
      'balanceAmount': balanceAmount,
      'status': status,
      'invoiceDate': invoiceDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerName: json['customerName'] as String?,
      items: (json['items'] as List).map((e) => InvoiceItemModel.fromJson(e)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balanceAmount'] as num).toDouble(),
      status: json['status'] as String,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
