import 'package:hive/hive.dart';
import '../../domain/entities/payment_history_entity.dart';

part 'payment_history_model.g.dart';

/// Payment History Model for Hive storage
@HiveType(typeId: 3)
class PaymentHistoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? invoiceId;

  @HiveField(2)
  DateTime paymentDate;

  @HiveField(3)
  double paidAmount;

  @HiveField(4)
  String paymentMode;

  @HiveField(5)
  double previousDue;

  @HiveField(6)
  double remainingDue;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  PaymentHistoryModel({
    required this.id,
    this.invoiceId,
    required this.paymentDate,
    required this.paidAmount,
    required this.paymentMode,
    required this.previousDue,
    required this.remainingDue,
    this.notes,
    required this.createdAt,
  });

  /// Convert model to entity
  PaymentHistoryEntity toEntity() {
    return PaymentHistoryEntity(
      id: id,
      invoiceId: invoiceId,
      paymentDate: paymentDate,
      paidAmount: paidAmount,
      paymentMode: paymentMode,
      previousDue: previousDue,
      remainingDue: remainingDue,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Create model from entity
  factory PaymentHistoryModel.fromEntity(PaymentHistoryEntity entity) {
    return PaymentHistoryModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      paymentDate: entity.paymentDate,
      paidAmount: entity.paidAmount,
      paymentMode: entity.paymentMode,
      previousDue: entity.previousDue,
      remainingDue: entity.remainingDue,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'paymentDate': paymentDate.toIso8601String(),
      'paidAmount': paidAmount,
      'paymentMode': paymentMode,
      'remainingDue': remainingDue,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String?,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      paymentMode: json['paymentMode'] as String,
      previousDue: 0.0, // Default or adjust if needed
      remainingDue: (json['remainingDue'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
