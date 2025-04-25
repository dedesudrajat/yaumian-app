// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 5;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      creatorId: fields[3] as String,
      accessCode: fields[4] as String,
      memberIds: (fields[5] as List).cast<String>(),
      pendingInvites: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      groupAmalans: (fields[8] as List).cast<GroupAmalan>(),
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.creatorId)
      ..writeByte(4)
      ..write(obj.accessCode)
      ..writeByte(5)
      ..write(obj.memberIds)
      ..writeByte(6)
      ..write(obj.pendingInvites)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.groupAmalans);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupAmalanAdapter extends TypeAdapter<GroupAmalan> {
  @override
  final int typeId = 6;

  @override
  GroupAmalan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupAmalan(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      createdAt: fields[4] as DateTime,
      memberProgress: (fields[5] as Map).cast<String, GroupMemberProgress>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupAmalan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.memberProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAmalanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupMemberProgressAdapter extends TypeAdapter<GroupMemberProgress> {
  @override
  final int typeId = 7;

  @override
  GroupMemberProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupMemberProgress(
      userId: fields[0] as String,
      completed: fields[1] as bool,
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GroupMemberProgress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMemberProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupInvitationAdapter extends TypeAdapter<GroupInvitation> {
  @override
  final int typeId = 8;

  @override
  GroupInvitation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupInvitation(
      id: fields[0] as String,
      groupId: fields[1] as String,
      groupName: fields[2] as String,
      inviterName: fields[3] as String,
      inviteeEmail: fields[4] as String,
      createdAt: fields[5] as DateTime,
      accepted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GroupInvitation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.groupName)
      ..writeByte(3)
      ..write(obj.inviterName)
      ..writeByte(4)
      ..write(obj.inviteeEmail)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.accepted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupInvitationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
