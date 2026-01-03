import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';
import '../../data/repositories/routes_repository.dart';
import '../../services/statistics_service.dart';
import '../../services/share_service.dart';

/// Controller for arrival screen
class ArrivalController extends ChangeNotifier {
  final RoutesRepository _routesRepository;
  final StatisticsService _statisticsService;
  final ShareService _shareService;

  final String routeId;
  final int actualDurationSeconds;

  RouteEntity? _route;
  int _currentStreak = 0;
  bool _isLoading = true;
  String? _error;

  ArrivalController({
    required this.routeId,
    required this.actualDurationSeconds,
    RoutesRepository? routesRepository,
    StatisticsService? statisticsService,
    ShareService? shareService,
  })  : _routesRepository = routesRepository ?? RoutesRepository(),
        _statisticsService = statisticsService ?? StatisticsService(),
        _shareService = shareService ?? ShareService();

  // ============================================
  // GETTERS
  // ============================================

  RouteEntity? get route => _route;
  int get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadData() async {
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

      // Load statistics for streak
      final stats = await _statisticsService.getStatistics();
      _currentStreak = stats.currentStreak;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // ACTIONS
  // ============================================

  /// Share the completion (text only for now)
  Future<void> shareCompletion() async {
    if (_route == null) return;

    final duration = Duration(seconds: actualDurationSeconds);
    final shareText = ShareService.generateShareText(
      routeTitle: _route!.title,
      duration: duration,
      streak: _currentStreak,
    );

    await _shareService.shareText(shareText);
  }
}
