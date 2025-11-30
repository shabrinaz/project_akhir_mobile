import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static const String _dbName = 'donasi_app.db';
  static const int _dbVersion = 1;

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      // kalau nanti mau upgrade versi, bisa pakai onUpgrade
      // onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        points INTEGER DEFAULT 0,
        profile_image_path TEXT
      )
    ''');

    // TODO: kalau kamu punya tabel lain (donasi, dsb) bikin juga di sini
  }

  // ===================== USER =====================

  /// Dipakai di RegisterScreen
  /// return:
  ///  >0  = berhasil (rowId)
  ///  -1  = username sudah ada (UNIQUE constraint gagal)
  ///   0  = error lain
  Future<int> registerUser(User user) async {
    final db = await database;

    try {
      final id = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return id; // > 0 kalau sukses
    } on DatabaseException catch (e) {
      // cek kalau error karena UNIQUE (username sudah dipakai)
      if (e.isUniqueConstraintError()) {
        return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Kalau kamu pengin pakai nama insertUser juga, boleh pakai wrapper ini:
  Future<int> insertUser(User user) async {
    return registerUser(user);
  }

  // Login: cari user berdasarkan username + password
  Future<User?> loginUser(String username, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Ambil user berdasarkan ID
  Future<User?> getUserById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Update user (points, profileImagePath, dll)
  Future<int> updateUser(User user) async {
    final db = await database;

    if (user.id == null) {
      throw ArgumentError('User ID tidak boleh null saat update');
    }

    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // (opsional) hapus user
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // (opsional) ambil semua user (buat debug)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
