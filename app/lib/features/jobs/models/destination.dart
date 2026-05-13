import 'package:hive_flutter/hive_flutter.dart';

/// Hive typeIds reserved for the Relayit data model:
///   0 - Job
///   1 - Destination
///   2 - LogEntry
///   3 - DeliveryReceipt
///   4 - SourceType
///   5 - DestinationType
///   6 - DeliveryStatus

@HiveType(typeId: 5)
enum DestinationType {
  @HiveField(0)
  whatsapp,
  @HiveField(1)
  email,
  @HiveField(2)
  sms,
}

class DestinationTypeAdapter extends TypeAdapter<DestinationType> {
  @override
  final int typeId = 5;

  @override
  DestinationType read(BinaryReader reader) {
    final index = reader.readByte();
    return DestinationType.values[index.clamp(
      0,
      DestinationType.values.length - 1,
    )];
  }

  @override
  void write(BinaryWriter writer, DestinationType obj) {
    writer.writeByte(obj.index);
  }
}

@HiveType(typeId: 1)
class Destination {
  Destination({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    this.isActive = true,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DestinationType type;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final String value;

  @HiveField(4)
  final bool isActive;

  Destination copyWith({
    String? id,
    DestinationType? type,
    String? label,
    String? value,
    bool? isActive,
  }) => Destination(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label ?? this.label,
    value: value ?? this.value,
    isActive: isActive ?? this.isActive,
  );
}

class DestinationAdapter extends TypeAdapter<Destination> {
  @override
  final int typeId = 1;

  @override
  Destination read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return Destination(
      id: fields[0] as String,
      type: fields[1] as DestinationType,
      label: fields[2] as String,
      value: fields[3] as String,
      isActive: (fields[4] as bool?) ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Destination obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.isActive);
  }
}
