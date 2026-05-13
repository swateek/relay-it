import 'package:hive_flutter/hive_flutter.dart';

import 'destination.dart';

@HiveType(typeId: 4)
enum SourceType {
  @HiveField(0)
  senderId,
  @HiveField(1)
  phoneNumber,
  @HiveField(2)
  contactName,
}

class SourceTypeAdapter extends TypeAdapter<SourceType> {
  @override
  final int typeId = 4;

  @override
  SourceType read(BinaryReader reader) {
    final index = reader.readByte();
    return SourceType.values[index.clamp(0, SourceType.values.length - 1)];
  }

  @override
  void write(BinaryWriter writer, SourceType obj) {
    writer.writeByte(obj.index);
  }
}

@HiveType(typeId: 0)
class Job {
  Job({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.sourceValue,
    required this.destinations,
    required this.createdAt,
    this.isActive = true,
    this.lastFiredAt,
    this.deliveryCount = 0,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final SourceType sourceType;

  @HiveField(3)
  final String sourceValue;

  @HiveField(4)
  final List<Destination> destinations;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? lastFiredAt;

  @HiveField(8)
  final int deliveryCount;

  Job copyWith({
    String? id,
    String? name,
    SourceType? sourceType,
    String? sourceValue,
    List<Destination>? destinations,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastFiredAt,
    int? deliveryCount,
  }) => Job(
    id: id ?? this.id,
    name: name ?? this.name,
    sourceType: sourceType ?? this.sourceType,
    sourceValue: sourceValue ?? this.sourceValue,
    destinations: destinations ?? this.destinations,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastFiredAt: lastFiredAt ?? this.lastFiredAt,
    deliveryCount: deliveryCount ?? this.deliveryCount,
  );
}

class JobAdapter extends TypeAdapter<Job> {
  @override
  final int typeId = 0;

  @override
  Job read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return Job(
      id: fields[0] as String,
      name: fields[1] as String,
      sourceType: fields[2] as SourceType,
      sourceValue: fields[3] as String,
      destinations: (fields[4] as List).cast<Destination>(),
      isActive: (fields[5] as bool?) ?? true,
      createdAt: fields[6] as DateTime,
      lastFiredAt: fields[7] as DateTime?,
      deliveryCount: (fields[8] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Job obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sourceType)
      ..writeByte(3)
      ..write(obj.sourceValue)
      ..writeByte(4)
      ..write(obj.destinations)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastFiredAt)
      ..writeByte(8)
      ..write(obj.deliveryCount);
  }
}
