import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'article_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            points INTEGER
          )
          '''
        );
      },
    );
  }

  // Hashing Password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // REGISTRASI
  Future<int> registerUser(User user) async {
    final db = await database;
    final hashedPassword = _hashPassword(user.password);
    
    final userToInsert = User(
      username: user.username,
      password: hashedPassword,
      points: user.points,
    );

    try {
      return await db.insert('users', userToInsert.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      print("Registrasi gagal: Username sudah terdaftar. $e");
      return -1; 
    }
  }

  // LOGIN
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Tambah poin user
  Future<void> addPoints(int userId, int amount) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET points = points + ? WHERE id = ?',
      [amount, userId],
    );
  }
}