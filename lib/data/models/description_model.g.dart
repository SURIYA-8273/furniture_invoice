// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'description_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DescriptionModelAdapter extends TypeAdapter<DescriptionModel> {
  @override
  final int typeId = 10;

  @override
  DescriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DescriptionModel(
      id: fields[0] as String,
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DescriptionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DescriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
