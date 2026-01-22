// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessProfileModelAdapter extends TypeAdapter<BusinessProfileModel> {
  @override
  final int typeId = 0;

  @override
  BusinessProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessProfileModel(
      id: fields[0] as String,
      businessName: fields[1] as String,
      logoPath: fields[2] as String?,
      whatsappNumber: fields[3] as String?,
      primaryPhone: fields[4] as String?,
      additionalPhone: fields[5] as String?,
      instagramId: fields[6] as String?,
      websiteUrl: fields[7] as String?,
      gstNumber: fields[8] as String?,
      businessAddress: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessProfileModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.businessName)
      ..writeByte(2)
      ..write(obj.logoPath)
      ..writeByte(3)
      ..write(obj.whatsappNumber)
      ..writeByte(4)
      ..write(obj.primaryPhone)
      ..writeByte(5)
      ..write(obj.additionalPhone)
      ..writeByte(6)
      ..write(obj.instagramId)
      ..writeByte(7)
      ..write(obj.websiteUrl)
      ..writeByte(8)
      ..write(obj.gstNumber)
      ..writeByte(9)
      ..write(obj.businessAddress)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
