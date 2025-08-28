import 'package:uuid/uuid.dart';

enum PaymentStatus { pending, paid, overdue }

enum PaymentType { prepaid, postpaid }

class Session {
  final String id;
  final String customerId;
  final String machineId;
  final DateTime startTime;
  DateTime? endTime;
  PaymentStatus paymentStatus;
  PaymentType paymentType;
  double hourlyRate;
  double? finalAmount;
  String? notes;

  Session({
    String? id,
    required this.customerId,
    required this.machineId,
    required this.startTime,
    this.endTime,
    this.paymentStatus = PaymentStatus.pending,
    required this.paymentType,
    required this.hourlyRate,
    this.finalAmount,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Duration get duration {
    return (endTime ?? DateTime.now()).difference(startTime);
  }

  double get currentAmount {
    final hours = duration.inMinutes / 60.0;
    return hours * hourlyRate;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'machineId': machineId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'paymentStatus': paymentStatus.index,
      'paymentType': paymentType.index,
      'hourlyRate': hourlyRate,
      'finalAmount': finalAmount,
      'notes': notes,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      customerId: map['customerId'],
      machineId: map['machineId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      paymentStatus: PaymentStatus.values[map['paymentStatus']],
      paymentType: PaymentType.values[map['paymentType']],
      hourlyRate: map['hourlyRate'],
      finalAmount: map['finalAmount'],
      notes: map['notes'],
    );
  }
}
