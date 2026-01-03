import '../data/repositories/session_repository.dart';
import '../domain/entities/session_entity.dart';
import '../core/utils/date_utils.dart';

/// Statistics data container
class SessionStatistics {
  /// Sessions completed today
  final int todaySessions;
  final int todayFocusTimeSeconds;

  /// Sessions in last 7 days
  final int weekSessions;
  final int weekFocusTimeSeconds;

  /// All-time statistics
  final int allTimeSessions;
  final int allTimeFocusTimeSeconds;

  /// Current streak (consecutive days with at least 1 session)
  final int currentStreak;

  const SessionStatistics({
    required this.todaySessions,
    required this.todayFocusTimeSeconds,
    required this.weekSessions,
    required this.weekFocusTimeSeconds,
    required this.allTimeSessions,
    required this.allTimeFocusTimeSeconds,
    required this.currentStreak,
  });

  /// Empty statistics
  static const SessionStatistics empty = SessionStatistics(
    todaySessions: 0,
    todayFocusTimeSeconds: 0,
    weekSessions: 0,
    weekFocusTimeSeconds: 0,
    allTimeSessions: 0,
    allTimeFocusTimeSeconds: 0,
    currentStreak: 0,
  );

  /// Today's focus time as Duration
  Duration get todayFocusTime => Duration(seconds: todayFocusTimeSeconds);

  /// Week's focus time as Duration
  Duration get weekFocusTime => Duration(seconds: weekFocusTimeSeconds);

  /// All-time focus time as Duration
  Duration get allTimeFocusTime => Duration(seconds: allTimeFocusTimeSeconds);
}

/// Service for calculating session statistics
class StatisticsService {
  final SessionRepository _sessionRepository;

  StatisticsService({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? SessionRepository();

  /// Calculate all statistics
  Future<SessionStatistics> getStatistics() async {
    final now = DateTime.now();

    // Get today's sessions
    final todaySessions = await _getTodayStats(now);

    // Get last 7 days sessions
    final weekSessions = await _getWeekStats(now);

    // Get all-time sessions
    final allTimeSessions = await _getAllTimeStats();

    // Calculate streak
    final streak = await _calculateStreak(now);

    return SessionStatistics(
      todaySessions: todaySessions.$1,
      todayFocusTimeSeconds: todaySessions.$2,
      weekSessions: weekSessions.$1,
      weekFocusTimeSeconds: weekSessions.$2,
      allTimeSessions: allTimeSessions.$1,
      allTimeFocusTimeSeconds: allTimeSessions.$2,
      currentStreak: streak,
    );
  }

  /// Get today's statistics (count, total seconds)
  Future<(int, int)> _getTodayStats(DateTime now) async {
    final startOfToday = AppDateUtils.startOfDay(now);
    final endOfToday = AppDateUtils.endOfDay(now);

    final sessions = await _sessionRepository.getSessionsInRange(
      startOfToday,
      endOfToday,
    );

    return _aggregateSessions(sessions);
  }

  /// Get last 7 days statistics (count, total seconds)
  Future<(int, int)> _getWeekStats(DateTime now) async {
    final startOfWeek = AppDateUtils.startOfDay(
      now.subtract(const Duration(days: 6)),
    );
    final endOfToday = AppDateUtils.endOfDay(now);

    final sessions = await _sessionRepository.getSessionsInRange(
      startOfWeek,
      endOfToday,
    );

    return _aggregateSessions(sessions);
  }

  /// Get all-time statistics (count, total seconds)
  Future<(int, int)> _getAllTimeStats() async {
    final sessions = await _sessionRepository.getAllCompletedSessions();
    return _aggregateSessions(sessions);
  }

  /// Aggregate sessions into count and total time
  (int, int) _aggregateSessions(List<SessionEntity> sessions) {
    int count = 0;
    int totalSeconds = 0;

    for (final session in sessions) {
      if (session.completed) {
        count++;
        totalSeconds += session.actualDurationSeconds;
      }
    }

    return (count, totalSeconds);
  }

  /// Calculate current streak
  ///
  /// Streak rules:
  /// - 1 day = at least 1 completed session that day
  /// - Streak counts consecutive days going backwards from today
  /// - Today counts if at least 1 session completed today
  /// - If no session today, check if yesterday had one (streak continues)
  Future<int> _calculateStreak(DateTime now) async {
    int streak = 0;
    DateTime checkDate = AppDateUtils.startOfDay(now);

    // Check today first
    final todaySessions = await _sessionRepository.getSessionsForDate(checkDate);
    final hasSessionToday = todaySessions.any((s) => s.completed);

    if (hasSessionToday) {
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // If no session today, start checking from yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Check previous days
    // Limit to 365 days to avoid infinite loops
    for (int i = 0; i < 365; i++) {
      final daySessions = await _sessionRepository.getSessionsForDate(checkDate);
      final hasSession = daySessions.any((s) => s.completed);

      if (hasSession) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
