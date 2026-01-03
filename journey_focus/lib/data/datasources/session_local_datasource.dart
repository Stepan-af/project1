import 'package:sqflite/sqflite.dart';
import '../models/session_model.dart';
import 'database_helper.dart';
import '../../core/constants/storage_keys.dart';

/// Local data source for sessions
/// Handles CRUD operations in SQLite database
class SessionLocalDatasource {
  /// Insert a new session
  Future<void> insertSession(SessionModel session) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      StorageKeys.sessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing session
  Future<void> updateSession(SessionModel session) async {
    final db = await DatabaseHelper.database;
    await db.update(
      StorageKeys.sessionsTable,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Get active session (finished_at is null)
  Future<SessionModel?> getActiveSession() async {
    final db = await DatabaseHelper.database;
    final results = await db.query(
      StorageKeys.sessionsTable,
      where: 'finished_at IS NULL',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return SessionModel.fromMap(results.first);
  }

  /// Get all completed sessions
  Future<List<SessionModel>> getAllCompletedSessions() async {
    final db = await DatabaseHelper.database;
    final results = await db.query(
      StorageKeys.sessionsTable,
      where: 'finished_at IS NOT NULL',
      orderBy: 'started_at DESC',
    );

    return results.map((map) => SessionModel.fromMap(map)).toList();
  }

  /// Get sessions within a date range (for statistics)
  Future<List<SessionModel>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await DatabaseHelper.database;
    final results = await db.query(
      StorageKeys.sessionsTable,
      where: 'started_at >= ? AND started_at < ? AND completed = 1',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'started_at DESC',
    );

    return results.map((map) => SessionModel.fromMap(map)).toList();
  }

  /// Get session by ID
  Future<SessionModel?> getSessionById(String id) async {
    final db = await DatabaseHelper.database;
    final results = await db.query(
      StorageKeys.sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return SessionModel.fromMap(results.first);
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      StorageKeys.sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get completed sessions for a specific date (for streak calculation)
  Future<List<SessionModel>> getSessionsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSessionsInRange(startOfDay, endOfDay);
  }
}
