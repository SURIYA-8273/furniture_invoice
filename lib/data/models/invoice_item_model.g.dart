// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceItemModelAdapter extends TypeAdapter<InvoiceItemModel> {
  @override
  final int typeId = 5;

  @override
  InvoiceItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItemModel(
      id: fields[0] as String,
      productName: fields[1] as String,
      size: fields[2] as String,
      squareFeet: fields[3] as double,
      quantity: fields[4] as int,
      totalQuantity: fields[5] as double,
      mrp: fields[6] as double,
      totalAmount: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.squareFeet)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.totalQuantity)
      ..writeByte(6)
      ..write(obj.mrp)
      ..writeByte(7)
      ..write(obj.totalAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
