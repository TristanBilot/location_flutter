// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 1;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      (fields[0] as List)?.cast<int>(),
      (fields[1] as List)?.cast<Gender>(),
      fields[2] as bool,
      fields[3] as bool,
      fields[4] as bool,
      Map<String, bool>(), // WARNING
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.wantedAgeRange)
      ..writeByte(1)
      ..write(obj.wantedGenders)
      ..writeByte(2)
      ..write(obj.showMyprofile)
      ..writeByte(3)
      ..write(obj.showMyDistance)
      ..writeByte(4)
      ..write(obj.connected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
