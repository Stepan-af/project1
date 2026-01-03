import '../../domain/entities/session_entity.dart';

/// Data transfer object for Session
/// Handles SQLite serialization/deserialization
class SessionModel {
  final String id;
  final String routeId;
  final int startedAt; // Unix timestamp (milliseconds)
  final int? finishedAt; // Unix timestamp (milliseconds)
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final int completed; // SQLite doesn't have bool: 0 = false, 1 = true
  final int pausedDurationSeconds;
  final int? pausedAt; // Unix timestamp (milliseconds)

  SessionModel({
    required this.id,
    required this.routeId,
    required this.startedAt,
    this.finishedAt,
    required this.plannedDurationSeconds,
    this.actualDurationSeconds = 0,
    this.completed = 0,
    this.pausedDurationSeconds = 0,
    this.pausedAt,
  });

  /// Create from SQLite row
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as String,
      routeId: map['route_id'] as String,
      startedAt: map['started_at'] as int,
      finishedAt: map['finished_at'] as int?,
      plannedDurationSeconds: map['planned_duration_seconds'] as int,
      actualDurationSeconds: map['actual_duration_seconds'] as int? ?? 0,
      completed: map['completed'] as int? ?? 0,
      pausedDurationSeconds: map['paused_duration_seconds'] as int? ?? 0,
      pausedAt: map['paused_at'] as int?,
    );
  }

  /// Convert to SQLite row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'route_id': routeId,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'planned_duration_seconds': plannedDurationSeconds,
      'actual_duration_seconds': actualDurationSeconds,
      'completed': completed,
      'paused_duration_seconds': pausedDurationSeconds,
      'paused_at': pausedAt,
    };
  }

  /// Convert to domain entity
  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      routeId: routeId,
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
      finishedAt: finishedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(finishedAt!)
          : null,
      plannedDurationSeconds: plannedDurationSeconds,
      actualDurationSeconds: actualDurationSeconds,
      completed: completed == 1,
      pausedDurationSeconds: pausedDurationSeconds,
      pausedAt:
          pausedAt != null ? DateTime.fromMillisecondsSinceEpoch(pausedAt!) : null,
    );
  }

  /// Create from domain entity
  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      routeId: entity.routeId,
      startedAt: entity.startedAt.millisecondsSinceEpoch,
      finishedAt: entity.finishedAt?.millisecondsSinceEpoch,
      plannedDurationSeconds: entity.plannedDurationSeconds,
      actualDurationSeconds: entity.actualDurationSeconds,
      completed: entity.completed ? 1 : 0,
      pausedDurationSeconds: entity.pausedDurationSeconds,
      pausedAt: entity.pausedAt?.millisecondsSinceEpoch,
    );
  }
}
