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
      customerName: fields[13] as String?,
      items: (fields[2] as List).cast<InvoiceItemModel>(),
      subtotal: fields[3] as double,
      discount: fields[4] as double,
      gst: fields[5] as double,
      grandTotal: fields[6] as double,
      paidAmount: fields[7] as double,
      balanceAmount: fields[8] as double,
      status: fields[9] as String,
      invoiceDate: fields[10] as DateTime,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(13)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.gst)
      ..writeByte(6)
      ..write(obj.grandTotal)
      ..writeByte(7)
      ..write(obj.paidAmount)
      ..writeByte(8)
      ..write(obj.balanceAmount)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.invoiceDate)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
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
