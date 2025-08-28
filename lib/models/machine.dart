import 'package:uuid/uuid.dart';

enum MachineType { pc, console }

enum MachineStatus { available, inUse, maintenance }

class Machine {
  final String id;
  String name;
  MachineType type;
  String specifications;
  MachineStatus status;
  double hourlyRate;
  DateTime? lastMaintenanceDate;
  String? currentUserId;
  DateTime? sessionStartTime;

  Machine({
    String? id,
    required this.name,
    required this.type,
    required this.specifications,
    this.status = MachineStatus.available,
    required this.hourlyRate,
    this.lastMaintenanceDate,
    this.currentUserId,
    this.sessionStartTime,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'specifications': specifications,
      'status': status.index,
      'hourlyRate': hourlyRate,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'currentUserId': currentUserId,
      'sessionStartTime': sessionStartTime?.toIso8601String(),
    };
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      name: map['name'],
      type: MachineType.values[map['type']],
      specifications: map['specifications'],
      status: MachineStatus.values[map['status']],
      hourlyRate: map['hourlyRate'],
      lastMaintenanceDate: map['lastMaintenanceDate'] != null
          ? DateTime.parse(map['lastMaintenanceDate'])
          : null,
      currentUserId: map['currentUserId'],
      sessionStartTime: map['sessionStartTime'] != null
          ? DateTime.parse(map['sessionStartTime'])
          : null,
    );
  }

  Duration? get currentSessionDuration {
    if (sessionStartTime == null) return null;
    return DateTime.now().difference(sessionStartTime!);
  }

  double get currentSessionCost {
    if (sessionStartTime == null) return 0.0;
    final hours = currentSessionDuration!.inMinutes / 60.0;
    return hours * hourlyRate;
  }
}
