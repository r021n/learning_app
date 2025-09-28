// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttemptAdapter extends TypeAdapter<Attempt> {
  @override
  final int typeId = 2;

  @override
  Attempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attempt(
      id: fields[0] as String,
      materialId: fields[1] as String,
      userId: fields[2] as String,
      userAnswers: (fields[3] as List).cast<String>(),
      score: fields[4] as int,
      masteredTopics: (fields[5] as List).cast<String>(),
      unmasteredTopics: (fields[6] as List).cast<String>(),
      completedAt: fields[7] as DateTime,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Attempt obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userAnswers)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.masteredTopics)
      ..writeByte(6)
      ..write(obj.unmasteredTopics)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
