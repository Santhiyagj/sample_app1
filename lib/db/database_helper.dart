import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('restaurant.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableNumber INTEGER,
        itemName TEXT,
        quantity INTEGER,
        price REAL,
        status TEXT
      )
    ''');

    // Create table status table
    await db.execute('''
      CREATE TABLE table_status (
        table_number INTEGER PRIMARY KEY,
        status TEXT
      )
    ''');
  }

  // ------------------- Order Methods -------------------

  Future<void> insertOrder(int tableNumber, String itemName, int quantity, double price,
      {String status = "completed"}) async {
    final db = await instance.database;
    await db.insert('orders', {
      'tableNumber': tableNumber,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> fetchCompletedOrders() async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: ['completed'],
    );
  }

  Future<void> clearOrders() async {
    final db = await instance.database;
    await db.delete('orders');
  }

  // ------------------- Table Status Methods -------------------

  Future<void> saveTableStatus(int tableNumber, String status) async {
    final db = await instance.database;
    await db.insert(
      'table_status',
      {
        'table_number': tableNumber,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllTableStatuses() async {
    final db = await instance.database;
    return await db.query('table_status');
  }

  Future<void> clearTableStatuses() async {
    final db = await instance.database;
    await db.delete('table_status');
  }
}
