// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentHistoryModelAdapter extends TypeAdapter<PaymentHistoryModel> {
  @override
  final int typeId = 3;

  @override
  PaymentHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentHistoryModel(
      id: fields[0] as String,
      invoiceId: fields[1] as String?,
      paymentDate: fields[2] as DateTime,
      paidAmount: fields[3] as double,
      paymentMode: fields[4] as String,
      previousDue: fields[5] as double,
      remainingDue: fields[6] as double,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentHistoryModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceId)
      ..writeByte(2)
      ..write(obj.paymentDate)
      ..writeByte(3)
      ..write(obj.paidAmount)
      ..writeByte(4)
      ..write(obj.paymentMode)
      ..writeByte(5)
      ..write(obj.previousDue)
      ..writeByte(6)
      ..write(obj.remainingDue)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
