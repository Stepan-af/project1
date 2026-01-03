/// Domain entity representing a focus session
///
/// Session timing is based on timestamps, not tick counters.
/// This ensures correct time calculation even after app restart.
class SessionEntity {
  final String id;
  final String routeId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final bool completed;

  /// Accumulated paused time in seconds (for pause/resume support)
  final int pausedDurationSeconds;

  /// Timestamp when session was paused (null if not paused)
  final DateTime? pausedAt;

  const SessionEntity({
    required this.id,
    required this.routeId,
    required this.startedAt,
    this.finishedAt,
    required this.plannedDurationSeconds,
    this.actualDurationSeconds = 0,
    this.completed = false,
    this.pausedDurationSeconds = 0,
    this.pausedAt,
  });

  /// Check if session is currently paused
  bool get isPaused => pausedAt != null;

  /// Check if session is active (not finished)
  bool get isActive => finishedAt == null;

  /// Calculate elapsed seconds based on timestamps
  ///
  /// This method correctly handles:
  /// - Normal running state
  /// - Paused state
  /// - Accumulated pause time
  int calculateElapsedSeconds(DateTime now) {
    if (!isActive) {
      return actualDurationSeconds;
    }

    final int totalPausedSeconds = pausedDurationSeconds;

    // If currently paused, calculate from startedAt to pausedAt
    if (isPaused) {
      return pausedAt!.difference(startedAt).inSeconds - totalPausedSeconds;
    }

    // If running, calculate from startedAt to now
    return now.difference(startedAt).inSeconds - totalPausedSeconds;
  }

  /// Calculate remaining seconds
  int calculateRemainingSeconds(DateTime now) {
    final elapsed = calculateElapsedSeconds(now);
    final remaining = plannedDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// Calculate progress (0.0 to 1.0)
  double calculateProgress(DateTime now) {
    final elapsed = calculateElapsedSeconds(now);
    if (plannedDurationSeconds <= 0) return 1.0;
    final progress = elapsed / plannedDurationSeconds;
    return progress.clamp(0.0, 1.0);
  }

  /// Check if session has reached completion time
  bool hasReachedEnd(DateTime now) {
    return calculateRemainingSeconds(now) <= 0;
  }

  /// Create a copy with updated fields
  SessionEntity copyWith({
    String? id,
    String? routeId,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? plannedDurationSeconds,
    int? actualDurationSeconds,
    bool? completed,
    int? pausedDurationSeconds,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    bool clearFinishedAt = false,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      completed: completed ?? this.completed,
      pausedDurationSeconds:
          pausedDurationSeconds ?? this.pausedDurationSeconds,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SessionEntity(id: $id, routeId: $routeId, completed: $completed)';
}
