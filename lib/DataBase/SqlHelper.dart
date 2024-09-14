import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'workouts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise TEXT,
        weight REAL,
        repetitions INTEGER
      )
    ''');
  }

  Future<int> insertSet(String exercise, double weight, int repetitions) async {
    final db = await database;
    return await db.insert('workouts', {
      'exercise': exercise,
      'weight': weight,
      'repetitions': repetitions,
    });
  }

  Future<int> updateWorkout(SetModel set) async {
    final db = await database;
    return await db.update(
      'workouts',
      set.toMap(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final db = await database;
    return await db.query('workouts');
  }

  Future<int> deleteWorkout(id) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

