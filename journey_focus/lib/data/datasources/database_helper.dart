import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/storage_keys.dart';

/// SQLite database helper
/// Handles database initialization and schema creation
class DatabaseHelper {
  static Database? _database;

  /// Get database instance (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, StorageKeys.databaseName);

    return await openDatabase(
      path,
      version: StorageKeys.databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create database schema
  static Future<void> _onCreate(Database db, int version) async {
    // Sessions table
    await db.execute('''
      CREATE TABLE ${StorageKeys.sessionsTable} (
        id TEXT PRIMARY KEY,
        route_id TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        finished_at INTEGER,
        planned_duration_seconds INTEGER NOT NULL,
        actual_duration_seconds INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        paused_duration_seconds INTEGER DEFAULT 0,
        paused_at INTEGER
      )
    ''');

    // Index for faster queries by date (for statistics)
    await db.execute('''
      CREATE INDEX idx_sessions_started_at
      ON ${StorageKeys.sessionsTable}(started_at)
    ''');

    // Index for active session lookup
    await db.execute('''
      CREATE INDEX idx_sessions_finished_at
      ON ${StorageKeys.sessionsTable}(finished_at)
    ''');
  }

  /// Close database connection
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
