import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'waypoint.db';
  static const int databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE stops ADD COLUMN notes TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        trip_type TEXT NOT NULL,
        budget REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stops (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        planned_duration INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        actual_duration INTEGER,
        check_in_time TEXT,
        check_out_time TEXT,
        status TEXT NOT NULL DEFAULT 'planned',
        FOREIGN KEY (trip_id)
          REFERENCES trips(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_stops_trip_id
      ON stops(trip_id)
    ''');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
