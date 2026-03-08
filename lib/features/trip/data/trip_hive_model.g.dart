// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripHiveModelAdapter extends TypeAdapter<TripHiveModel> {
  @override
  final int typeId = 20;

  @override
  TripHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      carId: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      distanceMeters: fields[5] as double,
      isSynced: fields[6] as bool,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.carId)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.distanceMeters)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
