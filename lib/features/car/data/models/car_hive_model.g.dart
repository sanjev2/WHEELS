// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarHiveModelAdapter extends TypeAdapter<CarHiveModel> {
  @override
  final int typeId = 4;

  @override
  CarHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarHiveModel(
      id: fields[0] as String?,
      make: fields[1] as String,
      model: fields[2] as String,
      year: fields[3] as int,
      licensePlate: fields[4] as String,
      fuelType: fields[5] as String,
      boughtDate: fields[6] as DateTime,
      category: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CarHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.make)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.licensePlate)
      ..writeByte(5)
      ..write(obj.fuelType)
      ..writeByte(6)
      ..write(obj.boughtDate)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
