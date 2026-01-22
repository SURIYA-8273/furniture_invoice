import 'package:hive/hive.dart';
import '../../domain/entities/payment_entity.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 6)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String? invoiceId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String paymentMode;

  @HiveField(5)
  final DateTime paymentDate;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      customerId: entity.customerId,
      invoiceId: entity.invoiceId,
      amount: entity.amount,
      paymentMode: entity.paymentMode,
      paymentDate: entity.paymentDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      customerId: customerId,
      invoiceId: invoiceId,
      amount: amount,
      paymentMode: paymentMode,
      paymentDate: paymentDate,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentMode': paymentMode,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      invoiceId: json['invoiceId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
