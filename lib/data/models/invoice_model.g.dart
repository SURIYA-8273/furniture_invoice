// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 4;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      customerId: fields[2] as String,
      customerName: fields[3] as String,
      items: (fields[4] as List).cast<InvoiceItemModel>(),
      subtotal: fields[5] as double,
      discount: fields[6] as double,
      gst: fields[7] as double,
      grandTotal: fields[8] as double,
      paidAmount: fields[9] as double,
      balanceAmount: fields[10] as double,
      status: fields[11] as String,
      invoiceDate: fields[12] as DateTime,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.subtotal)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.gst)
      ..writeByte(8)
      ..write(obj.grandTotal)
      ..writeByte(9)
      ..write(obj.paidAmount)
      ..writeByte(10)
      ..write(obj.balanceAmount)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.invoiceDate)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
