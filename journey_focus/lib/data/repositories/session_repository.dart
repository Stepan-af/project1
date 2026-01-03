import '../datasources/session_local_datasource.dart';
import '../models/session_model.dart';
import '../../domain/entities/session_entity.dart';

/// Repository for sessions
/// Provides business-level access to session data
class SessionRepository {
  final SessionLocalDatasource _datasource;

  SessionRepository({SessionLocalDatasource? datasource})
      : _datasource = datasource ?? SessionLocalDatasource();

  /// Save a new session
  Future<void> saveSession(SessionEntity session) async {
    final model = SessionModel.fromEntity(session);
    await _datasource.insertSession(model);
  }

  /// Update an existing session
  Future<void> updateSession(SessionEntity session) async {
    final model = SessionModel.fromEntity(session);
    await _datasource.updateSession(model);
  }

  /// Get active (unfinished) session
  Future<SessionEntity?> getActiveSession() async {
    final model = await _datasource.getActiveSession();
    return model?.toEntity();
  }

  /// Get all completed sessions
  Future<List<SessionEntity>> getAllCompletedSessions() async {
    final models = await _datasource.getAllCompletedSessions();
    return models.map((m) => m.toEntity()).toList();
  }

  /// Get sessions in date range
  Future<List<SessionEntity>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = await _datasource.getSessionsInRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  /// Get session by ID
  Future<SessionEntity?> getSessionById(String id) async {
    final model = await _datasource.getSessionById(id);
    return model?.toEntity();
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _datasource.deleteSession(id);
  }

  /// Get completed sessions for a specific date
  Future<List<SessionEntity>> getSessionsForDate(DateTime date) async {
    final models = await _datasource.getSessionsForDate(date);
    return models.map((m) => m.toEntity()).toList();
  }
}
