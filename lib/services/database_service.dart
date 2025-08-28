import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/machine.dart';
import '../models/session.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gamezone.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        membershipType INTEGER NOT NULL,
        membershipStart TEXT,
        membershipEnd TEXT,
        balance REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE machines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        specifications TEXT NOT NULL,
        status INTEGER NOT NULL,
        hourlyRate REAL NOT NULL,
        lastMaintenanceDate TEXT,
        currentUserId TEXT,
        sessionStartTime TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        machineId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        paymentStatus INTEGER NOT NULL,
        paymentType INTEGER NOT NULL,
        hourlyRate REAL NOT NULL,
        finalAmount REAL,
        notes TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id),
        FOREIGN KEY (machineId) REFERENCES machines (id)
      )
    ''');
  }

  // Customer CRUD operations
  Future<String> createCustomer(Customer customer) async {
    final db = await database;
    await db.insert('customers', customer.toMap());
    return customer.id;
  }

  Future<Customer?> getCustomer(String id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final maps = await db.query('customers', orderBy: 'name');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<bool> updateCustomer(Customer customer) async {
    final db = await database;
    final count = await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    return count > 0;
  }

  Future<bool> deleteCustomer(String id) async {
    final db = await database;
    final count = await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Machine CRUD operations
  Future<String> createMachine(Machine machine) async {
    final db = await database;
    await db.insert('machines', machine.toMap());
    return machine.id;
  }

  Future<Machine?> getMachine(String id) async {
    final db = await database;
    final maps = await db.query('machines', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Machine.fromMap(maps.first);
  }

  Future<List<Machine>> getAllMachines() async {
    final db = await database;
    final maps = await db.query('machines', orderBy: 'name');
    return maps.map((map) => Machine.fromMap(map)).toList();
  }

  Future<bool> updateMachine(Machine machine) async {
    final db = await database;
    final count = await db.update(
      'machines',
      machine.toMap(),
      where: 'id = ?',
      whereArgs: [machine.id],
    );
    return count > 0;
  }

  Future<bool> deleteMachine(String id) async {
    final db = await database;
    final count = await db.delete('machines', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  // Session CRUD operations
  Future<String> createSession(Session session) async {
    final db = await database;
    await db.insert('sessions', session.toMap());
    return session.id;
  }

  Future<Session?> getSession(String id) async {
    final db = await database;
    final maps = await db.query('sessions', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Session.fromMap(maps.first);
  }

  Future<List<Session>> getActiveSessions() async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'endTime IS NULL',
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<List<Session>> getCustomerSessions(String customerId) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<bool> updateSession(Session session) async {
    final db = await database;
    final count = await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
    return count > 0;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
