import 'package:uuid/uuid.dart';

enum MembershipType { none, daily, weekly, monthly }

class Customer {
  final String id;
  String name;
  String email;
  String phone;
  MembershipType membershipType;
  DateTime? membershipStart;
  DateTime? membershipEnd;
  double balance;
  DateTime createdAt;

  Customer({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    this.membershipType = MembershipType.none,
    this.membershipStart,
    this.membershipEnd,
    this.balance = 0.0,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'membershipType': membershipType.index,
      'membershipStart': membershipStart?.toIso8601String(),
      'membershipEnd': membershipEnd?.toIso8601String(),
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      membershipType: MembershipType.values[map['membershipType']],
      membershipStart: map['membershipStart'] != null
          ? DateTime.parse(map['membershipStart'])
          : null,
      membershipEnd: map['membershipEnd'] != null
          ? DateTime.parse(map['membershipEnd'])
          : null,
      balance: map['balance'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
