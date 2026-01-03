import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/session_entity.dart';
import '../domain/entities/route_entity.dart';
import '../data/repositories/session_repository.dart';

/// Session engine manages the active focus session
///
/// Key features:
/// - Timestamp-based timer (not tick counters)
/// - Pause/resume support
/// - Session restoration after app restart
/// - Persistence to local database
class SessionEngine extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final Uuid _uuid = const Uuid();

  /// Currently active session
  SessionEntity? _activeSession;

  /// Current route for the active session
  RouteEntity? _activeRoute;

  /// Timer for UI updates (not for time tracking!)
  Timer? _updateTimer;

  /// Cached current time for consistent calculations within a frame
  DateTime _currentTime = DateTime.now();

  SessionEngine({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? SessionRepository();

  // ============================================
  // GETTERS
  // ============================================

  /// Get active session (null if no session running)
  SessionEntity? get activeSession => _activeSession;

  /// Get active route
  RouteEntity? get activeRoute => _activeRoute;

  /// Check if a session is currently active
  bool get hasActiveSession => _activeSession != null;

  /// Check if session is paused
  bool get isPaused => _activeSession?.isPaused ?? false;

  /// Check if session is running (active and not paused)
  bool get isRunning => hasActiveSession && !isPaused;

  /// Get elapsed seconds for current session
  int get elapsedSeconds {
    if (_activeSession == null) return 0;
    return _activeSession!.calculateElapsedSeconds(_currentTime);
  }

  /// Get remaining seconds for current session
  int get remainingSeconds {
    if (_activeSession == null) return 0;
    return _activeSession!.calculateRemainingSeconds(_currentTime);
  }

  /// Get progress (0.0 to 1.0) for current session
  double get progress {
    if (_activeSession == null) return 0.0;
    return _activeSession!.calculateProgress(_currentTime);
  }

  /// Check if session has reached end
  bool get hasReachedEnd {
    if (_activeSession == null) return false;
    return _activeSession!.hasReachedEnd(_currentTime);
  }

  // ============================================
  // SESSION LIFECYCLE
  // ============================================

  /// Start a new focus session for the given route
  Future<void> startSession(RouteEntity route) async {
    // Don't start if already have active session
    if (_activeSession != null) {
      throw StateError('Cannot start new session while another is active');
    }

    final now = DateTime.now();
    final session = SessionEntity(
      id: _uuid.v4(),
      routeId: route.id,
      startedAt: now,
      plannedDurationSeconds: route.durationSeconds,
    );

    // Save to database
    await _sessionRepository.saveSession(session);

    // Update state
    _activeSession = session;
    _activeRoute = route;
    _currentTime = now;

    // Start update timer
    _startUpdateTimer();

    notifyListeners();
  }

  /// Pause the current session
  Future<void> pauseSession() async {
    if (_activeSession == null || _activeSession!.isPaused) return;

    final now = DateTime.now();
    _activeSession = _activeSession!.copyWith(
      pausedAt: now,
    );

    // Persist pause state
    await _sessionRepository.updateSession(_activeSession!);

    // Stop update timer while paused
    _stopUpdateTimer();

    notifyListeners();
  }

  /// Resume a paused session
  Future<void> resumeSession() async {
    if (_activeSession == null || !_activeSession!.isPaused) return;

    final now = DateTime.now();
    final pausedAt = _activeSession!.pausedAt!;

    // Calculate additional pause duration
    final additionalPause = now.difference(pausedAt).inSeconds;
    final totalPausedDuration =
        _activeSession!.pausedDurationSeconds + additionalPause;

    _activeSession = _activeSession!.copyWith(
      pausedDurationSeconds: totalPausedDuration,
      clearPausedAt: true,
    );

    // Persist resume state
    await _sessionRepository.updateSession(_activeSession!);

    // Restart update timer
    _startUpdateTimer();
    _currentTime = now;

    notifyListeners();
  }

  /// Finish the session (either completed or manually stopped)
  ///
  /// Returns the completed session entity
  Future<SessionEntity> finishSession({bool completed = true}) async {
    if (_activeSession == null) {
      throw StateError('No active session to finish');
    }

    final now = DateTime.now();
    final elapsed = _activeSession!.calculateElapsedSeconds(now);

    final finishedSession = _activeSession!.copyWith(
      finishedAt: now,
      actualDurationSeconds: elapsed,
      completed: completed,
      clearPausedAt: true,
    );

    // Persist finished state
    await _sessionRepository.updateSession(finishedSession);

    // Clear state
    _stopUpdateTimer();
    final result = finishedSession;
    _activeSession = null;
    _activeRoute = null;

    notifyListeners();

    return result;
  }

  /// Cancel the current session without marking as completed
  Future<void> cancelSession() async {
    if (_activeSession == null) return;

    // Delete the session from database
    await _sessionRepository.deleteSession(_activeSession!.id);

    // Clear state
    _stopUpdateTimer();
    _activeSession = null;
    _activeRoute = null;

    notifyListeners();
  }

  // ============================================
  // SESSION RESTORATION
  // ============================================

  /// Restore active session from database (call on app startup)
  ///
  /// This handles the case where app was killed/backgrounded
  /// during an active session.
  ///
  /// The routeResolver can be async to load routes from repository.
  Future<bool> restoreSession(
    Future<RouteEntity> Function(String routeId) routeResolver,
  ) async {
    final savedSession = await _sessionRepository.getActiveSession();

    if (savedSession == null) {
      return false;
    }

    // Resolve the route (async)
    final route = await routeResolver(savedSession.routeId);

    // Check if session has already expired
    final now = DateTime.now();
    if (savedSession.hasReachedEnd(now)) {
      // Session expired while app was closed - auto-complete it
      final completed = savedSession.copyWith(
        finishedAt: now,
        actualDurationSeconds: savedSession.plannedDurationSeconds,
        completed: true,
        clearPausedAt: true,
      );
      await _sessionRepository.updateSession(completed);
      return false;
    }

    // Restore session
    _activeSession = savedSession;
    _activeRoute = route;
    _currentTime = now;

    // If not paused, start update timer
    if (!savedSession.isPaused) {
      _startUpdateTimer();
    }

    notifyListeners();
    return true;
  }

  // ============================================
  // TIMER MANAGEMENT
  // ============================================

  /// Start the update timer (1 second interval for UI updates)
  void _startUpdateTimer() {
    _stopUpdateTimer();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onTimerTick(),
    );
  }

  /// Stop the update timer
  void _stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Called every second to update UI
  void _onTimerTick() {
    _currentTime = DateTime.now();

    // Check if session has reached end
    if (_activeSession != null && hasReachedEnd) {
      // Auto-complete the session
      finishSession(completed: true);
      return;
    }

    notifyListeners();
  }

  /// Manually trigger a time update (useful after app resume)
  void refreshTime() {
    _currentTime = DateTime.now();
    notifyListeners();
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void dispose() {
    _stopUpdateTimer();
    super.dispose();
  }
}
