import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../services/session_engine.dart';
import '../../data/repositories/routes_repository.dart';

/// Controller for the session screen
/// Manages session state and provides data to the UI
class SessionController extends ChangeNotifier {
  final SessionEngine _sessionEngine;
  final RoutesRepository _routesRepository;

  RouteEntity? _route;
  bool _isLoading = true;
  String? _error;

  SessionController({
    required SessionEngine sessionEngine,
    RoutesRepository? routesRepository,
  })  : _sessionEngine = sessionEngine,
        _routesRepository = routesRepository ?? RoutesRepository();

  // ============================================
  // GETTERS
  // ============================================

  RouteEntity? get route => _route;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SessionEntity? get session => _sessionEngine.activeSession;
  bool get hasActiveSession => _sessionEngine.hasActiveSession;
  bool get isPaused => _sessionEngine.isPaused;
  bool get isRunning => _sessionEngine.isRunning;

  int get remainingSeconds => _sessionEngine.remainingSeconds;
  int get elapsedSeconds => _sessionEngine.elapsedSeconds;
  double get progress => _sessionEngine.progress;
  bool get hasReachedEnd => _sessionEngine.hasReachedEnd;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize session for a route
  Future<void> initialize(String routeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load route
      _route = await _routesRepository.getRouteById(routeId);

      if (_route == null) {
        _error = 'Route not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Start session if not already active
      if (!_sessionEngine.hasActiveSession) {
        await _sessionEngine.startSession(_route!);
      }

      // Listen to session engine changes
      _sessionEngine.addListener(_onSessionEngineChanged);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start session: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onSessionEngineChanged() {
    notifyListeners();
  }

  // ============================================
  // ACTIONS
  // ============================================

  Future<void> pauseSession() async {
    await _sessionEngine.pauseSession();
  }

  Future<void> resumeSession() async {
    await _sessionEngine.resumeSession();
  }

  Future<void> togglePauseResume() async {
    if (isPaused) {
      await resumeSession();
    } else {
      await pauseSession();
    }
  }

  /// Finish session early (with confirmation handled by UI)
  Future<SessionEntity> finishSession({bool completed = true}) async {
    return await _sessionEngine.finishSession(completed: completed);
  }

  Future<void> cancelSession() async {
    await _sessionEngine.cancelSession();
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void dispose() {
    _sessionEngine.removeListener(_onSessionEngineChanged);
    super.dispose();
  }
}
