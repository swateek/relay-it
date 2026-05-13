import 'package:hive_flutter/hive_flutter.dart';

import 'delivery_receipt.dart';

@HiveType(typeId: 2)
class LogEntry {
  LogEntry({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.sender,
    required this.messageBody,
    required this.receivedAt,
    required this.deliveries,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String jobId;

  @HiveField(2)
  final String jobName;

  @HiveField(3)
  final String sender;

  @HiveField(4)
  final String messageBody;

  @HiveField(5)
  final DateTime receivedAt;

  @HiveField(6)
  final List<DeliveryReceipt> deliveries;

  bool get allDelivered =>
      deliveries.isNotEmpty &&
      deliveries.every((d) => d.status == DeliveryStatus.success);

  int get successCount =>
      deliveries.where((d) => d.status == DeliveryStatus.success).length;
}

class LogEntryAdapter extends TypeAdapter<LogEntry> {
  @override
  final int typeId = 2;

  @override
  LogEntry read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return LogEntry(
      id: fields[0] as String,
      jobId: fields[1] as String,
      jobName: fields[2] as String,
      sender: fields[3] as String,
      messageBody: fields[4] as String,
      receivedAt: fields[5] as DateTime,
      deliveries: (fields[6] as List).cast<DeliveryReceipt>(),
    );
  }

  @override
  void write(BinaryWriter writer, LogEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jobId)
      ..writeByte(2)
      ..write(obj.jobName)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.messageBody)
      ..writeByte(5)
      ..write(obj.receivedAt)
      ..writeByte(6)
      ..write(obj.deliveries);
  }
}
