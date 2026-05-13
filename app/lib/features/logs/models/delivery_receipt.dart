import 'package:hive_flutter/hive_flutter.dart';

import '../../jobs/models/destination.dart';

@HiveType(typeId: 6)
enum DeliveryStatus {
  @HiveField(0)
  success,
  @HiveField(1)
  failed,
}

class DeliveryStatusAdapter extends TypeAdapter<DeliveryStatus> {
  @override
  final int typeId = 6;

  @override
  DeliveryStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return DeliveryStatus.values[index.clamp(
      0,
      DeliveryStatus.values.length - 1,
    )];
  }

  @override
  void write(BinaryWriter writer, DeliveryStatus obj) {
    writer.writeByte(obj.index);
  }
}

@HiveType(typeId: 3)
class DeliveryReceipt {
  DeliveryReceipt({
    required this.destinationId,
    required this.type,
    required this.label,
    required this.value,
    required this.status,
    required this.sentAt,
    this.errorMessage,
  });

  @HiveField(0)
  final String destinationId;

  @HiveField(1)
  final DestinationType type;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final String value;

  @HiveField(4)
  final DeliveryStatus status;

  @HiveField(5)
  final DateTime sentAt;

  @HiveField(6)
  final String? errorMessage;
}

class DeliveryReceiptAdapter extends TypeAdapter<DeliveryReceipt> {
  @override
  final int typeId = 3;

  @override
  DeliveryReceipt read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return DeliveryReceipt(
      destinationId: fields[0] as String,
      type: fields[1] as DestinationType,
      label: fields[2] as String,
      value: fields[3] as String,
      status: fields[4] as DeliveryStatus,
      sentAt: fields[5] as DateTime,
      errorMessage: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryReceipt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.destinationId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.sentAt)
      ..writeByte(6)
      ..write(obj.errorMessage);
  }
}
