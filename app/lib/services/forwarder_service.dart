import 'dart:async';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../features/jobs/models/destination.dart';
import '../features/jobs/models/job.dart';
import '../features/logs/models/delivery_receipt.dart';
import '../features/logs/models/log_entry.dart';
import 'storage_service.dart';

class ForwarderService {
  ForwarderService._();

  static const _uuid = Uuid();

  /// Forwards [body] received from [sender] to every active destination on [job].
  ///
  /// Persists a [LogEntry] containing one [DeliveryReceipt] per destination, and
  /// bumps the job's lastFiredAt / deliveryCount once. The method never throws.
  static Future<LogEntry> forward({
    required Job job,
    required String sender,
    required String body,
    DateTime? receivedAt,
  }) async {
    final received = receivedAt ?? DateTime.now();
    final receipts = <DeliveryReceipt>[];

    for (final dest in job.destinations) {
      if (!dest.isActive) continue;
      final receipt = await _deliverOne(dest, sender, body);
      receipts.add(receipt);
    }

    final entry = LogEntry(
      id: _uuid.v4(),
      jobId: job.id,
      jobName: job.name,
      sender: sender,
      messageBody: body,
      receivedAt: received,
      deliveries: receipts,
    );

    await StorageService.addLog(entry);

    final successes = receipts
        .where((r) => r.status == DeliveryStatus.success)
        .length;
    await StorageService.bumpDeliveryStats(
      job.id,
      firedAt: received,
      delta: successes,
    );

    return entry;
  }

  static Future<DeliveryReceipt> _deliverOne(
    Destination dest,
    String sender,
    String body,
  ) async {
    final now = DateTime.now();
    try {
      switch (dest.type) {
        case DestinationType.whatsapp:
          await _sendWhatsapp(dest.value, _composeBody(sender, body));
          return DeliveryReceipt(
            destinationId: dest.id,
            type: dest.type,
            label: dest.label,
            value: dest.value,
            status: DeliveryStatus.success,
            sentAt: now,
          );
        case DestinationType.email:
          await _sendEmail(dest.value, sender, body);
          return DeliveryReceipt(
            destinationId: dest.id,
            type: dest.type,
            label: dest.label,
            value: dest.value,
            status: DeliveryStatus.success,
            sentAt: now,
          );
        case DestinationType.sms:
          await _sendSms(dest.value, _composeBody(sender, body));
          return DeliveryReceipt(
            destinationId: dest.id,
            type: dest.type,
            label: dest.label,
            value: dest.value,
            status: DeliveryStatus.success,
            sentAt: now,
          );
      }
    } catch (e) {
      return DeliveryReceipt(
        destinationId: dest.id,
        type: dest.type,
        label: dest.label,
        value: dest.value,
        status: DeliveryStatus.failed,
        sentAt: now,
        errorMessage: e.toString(),
      );
    }
  }

  static String _composeBody(String sender, String body) =>
      'From $sender:\n$body';

  static Future<void> _sendWhatsapp(String number, String text) async {
    final sanitized = number.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse(
      'https://wa.me/$sanitized?text=${Uri.encodeComponent(text)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw Exception('Could not launch WhatsApp for $number');
    }
  }

  static Future<void> _sendEmail(
    String address,
    String sender,
    String body,
  ) async {
    await FlutterEmailSender.send(
      Email(
        recipients: [address],
        subject: 'Relayed SMS from $sender',
        body: body,
        isHTML: false,
      ),
    );
  }

  static Future<void> _sendSms(String number, String text) async {
    final completer = Completer<void>();
    bool resolved = false;
    void resolve(Object? err) {
      if (resolved) return;
      resolved = true;
      if (err == null) {
        completer.complete();
      } else {
        completer.completeError(err);
      }
    }

    try {
      await Telephony.instance.sendSms(
        to: number,
        message: text,
        statusListener: (status) {
          if (status == SendStatus.SENT) {
            resolve(null);
          }
        },
      );
      Timer(const Duration(seconds: 10), () {
        if (!resolved) {
          resolve(null);
        }
      });
    } catch (e) {
      resolve(e);
    }
    return completer.future;
  }
}
