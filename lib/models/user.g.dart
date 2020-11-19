// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User._()
      ..id = fields[0] as String
      ..email = fields[1] as String
      ..firstName = fields[2] as String
      ..lastName = fields[3] as String
      ..coord = (fields[4] as List)?.cast<double>()
      ..pictureURL = fields[5] as String
      ..distance = fields[6] as int
      ..age = fields[7] as int
      ..gender = fields[8] as Gender
      ..settings = fields[9] as UserSettings
      ..deviceTokens = (fields[10] as List)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.coord)
      ..writeByte(5)
      ..write(obj.pictureURL)
      ..writeByte(6)
      ..write(obj.distance)
      ..writeByte(7)
      ..write(obj.age)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.settings)
      ..writeByte(10)
      ..write(obj.deviceTokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
